#!/usr/local/bin/ruby
# $Id$

# Mozilla JTP 用のファイル取得、リンク修正、テンプレート追加などを行う

# 要件:
# ・URI モジュール

require 'nkf'
require 'net/http'
require 'uri'

TRANSLATOR = "高久雅生"
TRANSLATOR_ADDRESS = "masao@ulis.ac.jp"

JTP_NOTE = <<EOF
<p>
訳者： #{TRANSLATOR} &lt;<a href="mailto:#{TRANSLATOR_ADDRESS}">#{TRANSLATOR_ADDRESS}</a>&gt;<br>
<a href="THIS_URI">このドキュメントのオリジナルは mozilla.org において英語で公布されています。</a><br>
またドキュメントの管理の言語は現在も英語です。この日本語訳は、<br>
利用者の利便のためにもじら組和訳プロジェクトによって提供されたものです。<br>
フィードバックは英語で、元の著者に送って下さい。<br>
翻訳された文書の一覧は、現在以下のURLで見ることが出来ます。<br>
<a href="http://www.mozilla.gr.jp/jt/index.html">http://www.mozilla.gr.jp/jt/index.html</a>
</p>
EOF

META_CHARSET = %Q[<meta http-equiv="Content-Type" content="text/html;charset=EUC-JP">]

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
   # meta タグ
   contents.sub!(/<head[^>]*>.*<\/head>/im) {|head|
      unless head.sub!(/<meta\s+([^>]*)charset=[\w_\-]+/im) { "<meta #{$1}charset=EUC-JP" }
	 head.sub!(/<head[^>]*>/i) {|tag| tag + META_CHARSET }
      end
      head
   } or contents.sub!(/<body/i) { "<head>#{META_CHARSET}</head>\n<body" }

   # スタイル追加
   contents.sub!(/<head([^>]*>)/im) {|head| head + JT_STYLE }

   # リンク修正
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

   # テンプレート追加
   contents.gsub!(/<div id="footer">.*<\/div>/im) {|info|
      info.sub(/<\/div>$/){|tag| JTP_NOTE.gsub(/THIS_URI/, uri) + tag }
   } or contents.gsub!(/<\/body>/i) {|body| JTP_NOTE.gsub(/THIS_URI/, uri) + body }

   # 文字コード変換
   contents = NKF.nkf('-ec', contents)
else
   puts "No contents."
end

puts contents
