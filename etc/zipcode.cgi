#!/usr/local/bin/ruby
# -*- Ruby -*-
# $Id$

require 'cgi'
require 'dbi'

# escapeHTML のラッパー
def e(str)
   if str
      CGI.escapeHTML(str)
   else
      ""
   end
end

class String
   def format_zipcode
      self.sub(/^(\d\d\d)(\d?\d?\d?\d?)$/) {
	 if $2.size == 4
	    "〒" << $1 << "-" << $2
	 else
	    "〒" << $1
	 end
      }
   end
end

class ZipcodeCGI < CGI
   def keyword
      self.params['keyword'][0]
   end

   def title; "郵便番号検索"; end
   
   def html_header
      return <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev="made" href="mailto:masao@ulis.ac.jp">
<title>#{title}#{ keyword ? ": " + e(keyword) : "" }</title>
</head>
<body>
<h1>郵便番号検索</h1>
EOF
   end

   def html_footer
      "</body></html>\n"
   end
   
   def html_form
      return <<EOF
<form action="./zipcode.cgi" method="GET">
キーワード: <input type="text" name="keyword" value="#{e(keyword)}" size="40">
<input type="submit" value="検索">
</form>
EOF
   end
end

begin
   cgi = ZipcodeCGI.new

   print cgi.header("text/html; charset=EUC-JP")
   print cgi.html_header
   print cgi.html_form

   result = []
   if cgi.keyword
      dbh = DBI.connect("dbi:SQLite:zipcode.db")

      sql = ""
      case cgi.keyword
      when /^[0-9\-]+$/
	 sql << "where zipcode7 like '#{cgi.keyword.delete("-")}%'"
      else
	 sql << "where town like '%#{cgi.keyword.gsub('\'', '\'\'')}%'"
      end
      sth = dbh.prepare("select zipcode7, pref, city, town from zipcode #{sql}")
      sth.execute
      sth.each do |row|
	 zipcode7 = row.shift
	 result.push(zipcode7.format_zipcode << " " << row.join(" "))
      end
      sth.finish
   end

   if result
      puts "'#{e(cgi.keyword)}': #{result.size} 件ヒットしました"
      puts "<ul>"
      result.sort.each do |e|
	 puts "<li>" << e(e)
      end
      puts "</ul>"
   end
   print cgi.html_footer

rescue Exception
   print "Content-Type: text/plain\n\n"
   puts "#$! (#{$!.class})"
   puts ""
   puts $@.join( "\n" )
end
