#!/usr/local/bin/ruby
# $Id$

# Mozilla JTP �ѤΥե������������󥯽������ƥ�ץ졼���ɲäʤɤ�Ԥ�

# �׷�:
# ��URI �⥸�塼��

require 'nkf'
require 'net/http'
require 'uri'

TRANSLATOR = "��ײ���"
TRANSLATOR_ADDRESS = "masao@nii.ac.jp"

JTP_NOTE = <<EOF
<p class="docinfo">
���ԡ� #{TRANSLATOR} &lt;<a href="mailto:#{TRANSLATOR_ADDRESS}">#{TRANSLATOR_ADDRESS}</a>&gt;<br>
<a href="THIS_URI">
���Υɥ�����ȤΥ��ꥸ�ʥ�ϡ�mozilla.org �ˤ����ơ��Ѹ�Ǵ�������������Ƥ��ޤ���</a><br>
���������ϡ����ѼԤ����ؤΤ���� <a href="http://www.mozilla.gr.jp/jt/">�⤸���������ץ�������</a> �ˤ�ä��󶡤���Ƥ��ޤ���<br>
�ɥ�����Ȥ����Ƥ˴ؤ���ե����ɥХå��ϡ��Ѹ�ǡ���ʸ�����Ԥ����äƤ���������<br>
�����ɥ�����Ȱ����ʤɡ��ܤ�������� <a href="http://www.mozilla.gr.jp/jt/index.html">www.mozilla.gr.jp/jt</a> ��������������
</p>
EOF

META_CHARSET = %Q[<meta http-equiv="Content-Type" content="text/html;charset=EUC-JP">]

JT_STYLE = <<EOF
<style type="text/css" class="draft-comment">
.draft-comment {
    color: #20A040;
    font-size: 80%;
}
.orig { color:gray; }
</style>
EOF

def moz_jt_fix( uri )
   uri = URI::parse( uri )

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
      contents.sub!(/<head[^>]*>/im) {|head| head + JT_STYLE }

      # ��󥯽���
      contents.gsub!(/<(a|link)([^>]*)href=(["']?)http:\/\/(www.)?mozilla.org([!~*'();\/?:\@&=+\$,%#\w.-]+)\3/i) {|href|
         tag = $1
         attr = $2
         path = $5
         if path =~ /^\/webtools\/bonsai\/\w+\.cgi/
            href
         elsif path.nil?
            "<#{tag}#{attr}href=\"/\""
         else
            "<#{tag}#{attr}href=\"#{path}\""
         end
      }
      contents.gsub!(/<a([^>]*)href=(["']?)http:\/\/lxr.mozilla.org([!~*'();\/?:\@&=+\$,%#\w.-]*)\2/im) {|href|
         "<a#{$1}href=\"/lxr#{$3}\""
      }

      # �ƥ�ץ졼���ɲ�
      contents.gsub!(/<div id="footer">.*<\/div>/im) {|info|
         info.sub(/<\/div>$/){|tag| JTP_NOTE.gsub(/THIS_URI/, uri) + tag }
      } or contents.gsub!(/<\/body>/i) {|body| JTP_NOTE.gsub(/THIS_URI/, uri) + body }

      # ʸ���������Ѵ�
      contents = NKF.nkf('-ec', contents)
   end
   contents
end


if $0 == __FILE__
   unless ARGV[0]
      puts "Usage: #{$0} url"
      exit
   end
   if contents = moz_jt_fix( ARGV[0] )
      puts contents
   else
      puts "No contents."
   end
end
