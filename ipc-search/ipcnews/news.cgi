#!/usr/local/bin/ruby -wT
# -*- Ruby -*-
# ニュース情報を独自に提供する CGI

RCSID = '$Id$'

require "date"
require "base64"
# require "pstore"
require "cgi"

$:.unshift "."
require "ipcnews"

class String
   def auto_link
      self.gsub(/((https?|ftp):\/\/[;\/?:@&=+\$,A-Za-z0-9\-_.!~*'()]+)/,
		"<a href=\"\\1\">\\1</a>")
   end
end

class CGI
   def base_path
      if self.path_info
	 return "../" * self.path_info.count("/")
      else
	 return ""
      end
   end
   
   def html_header(title)
      csspath = self.base_path + "../../default.css"
      result = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="#{self.base_path}../../default.css" type="text/css">
<link rev=made href="mailto:masao@ulis.ac.jp">
<title>#{title}</title>
<style type="text/css">
img { border: 0px; }
.lastmodified { text-align: center }
.notice {
  font-size: smaller;
  font-weight: bold;
  text-align: center;
  border: thin dotted gray;
  padding: 5px;
}
.monthly-list {
  width: 80%;
  margin: auto;
  border: solid thin gray;
  padding: 1em;
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
本ページは個人的に運営しているものです。<br>
また、内容については、<a href="http://www.ulis.ac.jp/ipc/ipnews/ipcnews_new.html">センターニュース</a>を機械的に解析して生成したものなので、不正確な情報が含まれる可能性があります。より正確な情報については、<a href="http://www.ulis.ac.jp/ipc/">公式サイト</a>をご覧ください。
</p>
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="http://nile.ulis.ac.jp/~masao/">http://nile.ulis.ac.jp/~masao/</a>,
<a href="mailto:masao@ulis.ac.jp">masao@ulis.ac.jp</a>
</address>
<div class="id">#{RCSID}</div>
<div class="validator">
<a href="http://validator.w3.org/check/referer"><img src="http://www.w3.org/Icons/valid-html401" alt="Valid HTML 4.01!" height="31" width="88"></a>
<a href="http://jigsaw.w3.org/css-validator/check/referer"><img width="88" height="31" src="http://jigsaw.w3.org/css-validator/images/vcss" alt="Valid CSS!"></a>
<a href="http://feeds.archive.org/validator/check?url=http%3A%2F%2Fnile.ulis.ac.jp%2F%7Emasao%2Fipc-search%2Fipcnews%2Fipcnews-rss.rdf"><img src="#{self.base_path}valid-rss.png" width="88" height="31" alt="Valid RSS!"></a>
</div>
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
	    "<p class=\"lastmodified\">最終更新日: #{db[title].lastmodified}</p>" +
	    "<p>#{CGI.escapeHTML(db[title].description).auto_link}</p>" +
	    cgi.html_footer
      end
   else
      cgi.out() do
	 cgi.html_header("Not Found: 「" + CGI.escapeHTML(title) + "」") +
            "<p>記事「#{CGI.escapeHTML(title)}」は存在しません。</p>" +
	    cgi.html_footer
      end
   end
elsif cgi.path_info && cgi.path_info.length > 0
   year = cgi.path_info[1, 4].to_i
   month = cgi.path_info[6, 2].to_i
   result = db.values.find_all do |item|
      item.lastmodified.year == year &&
	 item.lastmodified.month == month
   end
   cgi.out() do
      cgi.html_header(CGI.escapeHTML("%04d-%02d" % [year, month])) +
	 "<ol>" +
	 result.collect do |item|
	    "<li><a href=\"#{cgi.script_name}?#{encode64(item.title).tr("\n","")}\">#{CGI.escapeHTML(item.title)}</a>" +
	    " [#{item.lastmodified}]\n"
         end.join +
	 "</ol>" +
	 cgi.html_footer
   end
else
   items = db.keys.sort {|a, b| db[b].lastmodified <=> db[a].lastmodified }
   monthlist_html = ""
   monthlist = db.values.collect do |item|
      "%04d-%02d" % [ item.lastmodified.year, item.lastmodified.month ]
   end
   this_year = false
   monthlist.uniq.sort.each do |m|
      year, month = m[0, 4], m[5, 2]
      if this_year != year
	 monthlist_html += "<br>" if this_year
	 monthlist_html += "#{year}: "
	 this_year = year
      end
      monthlist_html += " <a href=\"#{cgi.script_name}/#{m}\">#{month}</a>"
   end
   cgi.out() do
      cgi.html_header("センターニュースの閲覧") +
	 "<h2>最新ニュース <a href=\"ipcnews-rss.rdf\"><img src=\"rdf.png\" alt=\"RDF\" width=\"36\" height=\"14\"></a></h2>" +
	 "<ol>" +
	 items[0, 15].collect do |item|
	    "<li><a href=\"#{cgi.script_name}?#{encode64(item).tr("\n","")}\">#{item}</a>" +
	    " [#{db[item].lastmodified}]\n"
         end.join +
	 "</ol>" +
	 "<h2>月別一覧</h2>" +
	 "<div class=\"monthly-list\">" + monthlist_html + "</div>" +
	 # cgi.pre {
	 #    monthlist.uniq.sort.join("\n")
         # } +
	 cgi.html_footer
   end
end
