#!/usr/local/bin/ruby -wT
# -*- Ruby -*-
# $Id$

# ニュース情報を独自に提供する CGI

require "date"
require "base64"
# require "pstore"
require "cgi"

$:.unshift "."
require "ipcnews"

class CGI
   def html_header(title)
      result = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../../default.css" type="text/css">
<link rev=made href="mailto:masao@ulis.ac.jp">
<title>#{title}</title>
<style type="text/css">
.lastmodified { text-align: center }
.notice {
  font-weight: bold;
  text-align: center;
  border: thin dotted gray;
  padding: 5px;
}
</style>
</head>
<body>
<h1>#{title}</h1>
EOF
   end
   def html_footer
      result = <<EOF
<p class="notice">
本ページは個人的に運営しているもので、
<a href="http://www.ulis.ac.jp/ipc/">センター</a>
とは一切とは一切関係ありません。<br>
本ページの内容について、
<a href="http://www.ulis.ac.jp/ipc/">センター</a>
に問い合わせなどしないようお願いします。
</p>
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="http://nile.ulis.ac.jp/~masao/">http://nile.ulis.ac.jp/~masao/</a>,
<a href="mailto:masao@ulis.ac.jp">masao@ulis.ac.jp</a>
</address>
</body>
</html>
EOF
   end
end

db = Marshal.load(open("ipcnews.db"))
cgi = CGI.new("html4")
found = false

if cgi.query_string && cgi.query_string.length > 0
   title = decode64(cgi.query_string)
   found = db.has_key?(title)
   if found
      cgi.out() do
	 cgi.html_header(CGI.escapeHTML(title)) +
	    "<p>#{CGI.escapeHTML(db[title].description)}</p>" +
	    "<p class=\"lastmodified\">最終更新日: #{db[title].lastmodified}</p>" +
	    cgi.html_footer
      end
   else
      cgi.out() do
	 cgi.html_header("Not Found: " + CGI.escapeHTML(title)) +
            "<p>ニュース「#{CGI.escapeHTML(title)}」は存在しません。</p>" +
	    cgi.html_footer
      end
   end
else
   items = db.keys.sort {|a, b| db[b].lastmodified <=> db[a].lastmodified }
   cgi.out() do
      cgi.html_header("センターニュースの閲覧") +
	 "<ol>" +
	 items[0, 15].collect do |item|
  	    "<li><a href=\"?#{encode64(item).tr("\n","")}\">#{item}</a>" +
	    " [#{db[item].lastmodified}]\n"
         end.join +
	 "</ol>" +
	   cgi.html_footer
   end
end
