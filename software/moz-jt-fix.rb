#!/usr/local/bin/ruby
# $Id$

# Mozilla JTP �ѤΥե������������󥯽������ƥ�ץ졼���ɲäʤɤ�Ԥ�

# �׷�:
# ��URI �⥸�塼��

require 'nkf'
require 'net/http'
require 'uri'

TRANSLATOR = "��ײ���"
TRANSLATOR_ADDRESS = "masao@ulis.ac.jp"

JTP_NOTE = <<EOF

<div align="right"><font size="-1">
���ԡ� #{TRANSLATOR} &lt;<a href="mailto:#{TRANSLATOR_ADDRESS}">#{TRANSLATOR_ADDRESS}</a>&gt;<br>
<a href="THIS_URI">���Υɥ�����ȤΥ��ꥸ�ʥ�� mozilla.org �ˤ����ƱѸ�Ǹ��ۤ���Ƥ��ޤ���</a><br>
�ޤ��ɥ�����Ȥδ����θ���ϸ��ߤ�Ѹ�Ǥ����������ܸ����ϡ�<br>
���ѼԤ����ؤΤ���ˤ⤸���������ץ������Ȥˤ�ä��󶡤��줿��ΤǤ���<br>
�ե����ɥХå��ϱѸ�ǡ��������Ԥ����äƲ�������<br>
�������줿ʸ��ΰ����ϡ����߰ʲ���URL�Ǹ��뤳�Ȥ�����ޤ���<br>
<a href="http://www.mozilla.gr.jp/jt/index.html">http://www.mozilla.gr.jp/jt/index.html</a>
</font></div>
EOF

META_CHARSET = %Q[<meta name="http-equiv" content="text/html;charset=EUC-JP">]

JT_STYLE = <<EOF
<style type="text/css">
.comment {
    color: #20A040;
    font-size: 80%;
}
.draft-comment {
    color: #20A040;
    font-size: 80%;
}
.orig { color:gray; }
</style>
EOF

USAGE = "Usage: #{$0} url"

unless ARGV[0]
	puts USAGE
	exit
end

uri = URI::parse( ARGV[0] )

contents = nil

Net::HTTP.start( uri.host, uri.port ) {|http|
	response , = http.get(uri.request_uri)
	contents = response.body
}

if contents then
	# meta ����
	contents.sub!(/<head[^>]*>.*<\/head>/im) {|head|
		unless head.sub!(/<meta\s+([^>]*)charset=[\w_\-]+/im) { "<meta #{$1}charset=EUC-JP" }
			head.sub!(/<head[^>]*>/i) {|tag| tag + META_CHARSET }
		end
		head
	} or contents.sub!(/<body/i) { "<head>#{META_CHARSET}</head>\n<body" }

	# ���������ɲ�
	contents.sub!(/<head([^>]*>)/im) {|head| head + JT_STYLE }

	# ��󥯽���
	contents.gsub!(/<a([^>]*)href=(["']?)http:\/\/(www.)?mozilla.org([!~*'();\/?:\@&=+\$,%#\w.-]+)\2/i) {|ahref|
		attr = $1
		path = $4
		if path =~ /^\/webtools\/bonsai\/\w+\.cgi/
			ahref
		elsif path.nil?
			"<a#{attr}href=\"/\""
		else
			"<a#{attr}href=\"#{path}\""
		end
	}
	contents.gsub!(/<a([^>]*)href=(["']?)http:\/\/lxr.mozilla.org([!~*'();\/?:\@&=+\$,%#\w.-]*)\2/im) {|ahref|
		"<a#{$1}href=\"/lxr#{$3}\""
	}

	# �ƥ�ץ졼���ɲ�
	contents.gsub!(/<div class="documentinfo">.*<\/div>/im) {|info|
		info + JTP_NOTE.gsub(/THIS_URI/, uri)
	} or contents.gsub!(/<\/body>/i) {|body| JTP_NOTE.gsub(/THIS_URI/, uri) + body }

	# ʸ���������Ѵ�
	contents = NKF.nkf('-ec', contents)
else
	puts "No contents."
end

puts contents
