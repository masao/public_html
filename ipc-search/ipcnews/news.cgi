#!/usr/local/bin/ruby -wT
# -*- Ruby -*-
# $Id$

# �˥塼��������ȼ����󶡤��� CGI

require "date"
require "base64"
# require "pstore"
require "cgi"

$:.unshift "."
require "ipcnews"

class CGI
   def html_header(title)
      csspath = "../../default.css"
      csspath = "../" * self.path_info.count("/") + csspath if self.path_info
      result = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="#{csspath}" type="text/css">
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
�ܥڡ����ϸĿ�Ū�˱��Ĥ��Ƥ����Τǡ�
<a href="http://www.ulis.ac.jp/ipc/">���󥿡�</a>
�Ȥϰ��ڴط�����ޤ���<br>
�ܥڡ��������ƤˤĤ��ơ�
<a href="http://www.ulis.ac.jp/ipc/">���󥿡�</a>
���䤤��碌�ʤɤ��ʤ��褦���ꤤ���ޤ���
</p>
<hr>
<address>
��ײ��� (Takaku Masao)<br>
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
	    "<p class=\"lastmodified\">�ǽ�������: #{db[title].lastmodified}</p>" +
	    "<p>#{CGI.escapeHTML(db[title].description)}</p>" +
	    cgi.html_footer
      end
   else
      cgi.out() do
	 cgi.html_header("Not Found: ��" + CGI.escapeHTML(title) + "��") +
            "<p>������#{CGI.escapeHTML(title)}�פ�¸�ߤ��ޤ���</p>" +
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
      cgi.html_header("���󥿡��˥塼���α���") +
	 "<h2>���̰���</h2>" +
	 "<div class=\"monthly-list\">" + monthlist_html + "</div>" +
	 # cgi.pre {
	 #    monthlist.uniq.sort.join("\n")
         # } +
	 "<h2>�ǿ��˥塼�� <a href=\"ipcnews-rss.rdf\"><img src=\"rdf.png\" alt=\"RDF\" width=\"36\" height=\"14\" border=\"0\"</a></h2>" +
	 "<ol>" +
	 items[0, 15].collect do |item|
	    "<li><a href=\"#{cgi.script_name}?#{encode64(item).tr("\n","")}\">#{item}</a>" +
	    " [#{db[item].lastmodified}]\n"
         end.join +
	 "</ol>" +
	 cgi.html_footer
   end
end
