#!/usr/local/bin/ruby -wT
# -*- Ruby -*-
# �˥塼��������ȼ����󶡤��� CGI

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
span.date { font-size: smaller; color: maroon; }
.navbar { text-align: right; }
</style>
</head>
<body>
<h1>#{title}</h1>
EOF
   end

   def html_footer
      result = <<EOF
<p class="notice">
�ܥڡ����ϸĿ�Ū�˱��Ĥ��Ƥ���������Τ�ΤǤ���<br>
<a href="http://www.ulis.ac.jp/ipc/ipnews/ipcnews_new.html">���󥿡��˥塼��</a>�򵡳�Ū�˲��Ϥ����������Ƥ��뤿�ᡢ���Ƥ������Τʾ��󤬴ޤޤ�Ƥ����ǽ��������ޤ���������Τʾ���ˤĤ��Ƥϡ�<a href="http://www.ulis.ac.jp/ipc/">����������</a>��������������
</p>
<hr>
<address>
��ײ��� (Takaku Masao)<br>
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

   # ���̰���HTML����������
   def monthlist_html(db)
      list = db.values.collect do |item|
	 "%04d-%02d" % [ item.lastmodified.year, item.lastmodified.month ]
      end
      result = "<div class=\"monthly-list\">"
      this_year = false
      list.uniq.sort.each do |m|
	 year, month = m[0, 4], m[5, 2]
	 if this_year != year
	    result += "<br>" if this_year
	    result += "#{year}: "
	    this_year = year
	 end
	 result += " <a href=\"#{self.script_name}/#{m}\">#{month}</a>"
      end
      result += "</div>"
   end
end

db = Marshal.load(open("ipcnews.db"))
cgi = CGI.new

if cgi.query_string && cgi.query_string.length > 0
   title = decode64(cgi.query_string)
   if db.has_key?(title)
      cgi.out() do
	 month = "%04d-%02d" % [db[title].lastmodified.year,
	    			db[title].lastmodified.month]
	 cgi.html_header(CGI.escapeHTML(title)) +
	    "<p class=\"lastmodified\">" +
	    "�ǽ�������: #{db[title].lastmodified}" +
	    "</p>" +
	    "<p>#{CGI.escapeHTML(db[title].description).auto_link}</p>" +
	    "<div class=\"navbar\">" +
	    "<a href=\"#{cgi.script_name}\">[�ǿ�]</a>" +
	    " <a href=\"#{cgi.script_name}/#{month}\">[#{month}]</a>" +
	    "</div>" +
	    # cgi.monthlist_html(db) +
	    cgi.html_footer
      end
   else
      cgi.out() do
	 cgi.html_header("Not Found: ��" + CGI.escapeHTML(title) + "��") +
            "<p>������#{CGI.escapeHTML(title)}�פ�¸�ߤ��ޤ���</p>" +
	    "<div class=\"navbar\">" +
	    "<a href=\"#{cgi.script_name}\">[�ǿ�]</a>" +
	    "</div>" +
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
   result.sort!{|a, b| a.lastmodified <=> b.lastmodified }
   cgi.out() do
      cgi.html_header(CGI.escapeHTML("%04d-%02d" % [year, month])) +
	 "<ul>" +
	 result.collect do |item|
	    "<li><a href=\"#{cgi.script_name}?#{encode64(item.title).tr("\n","")}\">#{CGI.escapeHTML(item.title)}</a> <span class=\"date\">[#{item.lastmodified}]</span>"
         end.join +
	 "</ul>" +
	    "<div class=\"navbar\">" +
	    "<a href=\"#{cgi.script_name}\">[�ǿ�]</a>" +
	    "</div>" +
	 cgi.html_footer
   end
else
   items = db.keys.sort {|a, b| db[b].lastmodified <=> db[a].lastmodified }
   cgi.out() do
      cgi.html_header("���󥿡��˥塼���α���") +
	 "<h2>�ǿ��˥塼�� <a href=\"ipcnews-rss.rdf\"><img src=\"rdf.png\" alt=\"RDF\" width=\"36\" height=\"14\"></a></h2>" +
	 "<ol>" +
	 items[0, 15].collect do |item|
	    "<li><a href=\"#{cgi.script_name}?#{encode64(item).tr("\n","")}\">#{item}</a>" +
	    " <span class=\"date\">[#{db[item].lastmodified}]</span>\n"
         end.join +
	 "</ol>" +
	 "<h2>���̰���</h2>" +
	 cgi.monthlist_html(db) +
	 # cgi.pre {
	 #    monthlist.uniq.sort.join("\n")
         # } +
	 cgi.html_footer
   end
end
