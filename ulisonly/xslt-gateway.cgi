#!/usr/local/bin/perl -w
# -*- CPerl -*-
# $Id$

use strict;
use CGI qw/:cgi/;
use CGI::Carp qw(fatalsToBrowser);

### 大域変数

my $TITLE = 'XSLT ゲートウェイ';
my $FROM = 'masao@ulis.ac.jp';

my $HTML_HEAD = <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev=made href="mailto:$FROM">
<title>$TITLE</title>
</head>
<body>
<h1>$TITLE</h1>
<p>XMLとXSLTを入力すると、変換結果を確認できます。</p>
<p><strong>注意:</strong></p>
<ul>
<li>ファイル指定の方が優先されます。ファイル指定しない場合は、テキストエリアの内容が使われます。
<li>テキストエリアでの XML 宣言は、必ず<code>encoding="EUC-JP"</code>を使ってください。
<li>XSLTでは<code>&lt;xsl:output encoding="EUC-JP"&gt;</code>としないと、文字化けします。
</ul>
<hr>
EOF

my $DEFAULT_SOURCE = <<EOF;
<?xml version="1.0" encoding="EUC-JP"?>
<ほげ>
ふがふが
</ほげ>
EOF

my $DEFAULT_STYLESHEET = <<EOF;
<?xml version="1.0" encoding="EUC-JP"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns="http://www.w3.org/1999/xhtml"
               version="1.0">
<xsl:output method="html" encoding="EUC-JP"/>

<xsl:template match="/">
<html>
  <body>
  <xsl:apply-templates/>
  </body>
</html>
</xsl:template>

</xsl:transform>
EOF

### CGI 引数
my $source = param('source') || $DEFAULT_SOURCE;
my $source_f = param('source_f') || '';
my $stylesheet = param('stylesheet') || $DEFAULT_STYLESHEET;
my $stylesheet_f = param('stylesheet_f') || '';

my $xml = length(param("source_f")) ? read_data($source_f) : $source;
my $xslt = length(param("stylesheet_f")) ? read_data($stylesheet_f) : $stylesheet;

main();
sub main {
    print header("text/html; charset=EUC-JP");
    print $HTML_HEAD;
    if (defined param('submit')) {
	my $result = exec_xslt();
	$result = escape_html($result);
	print <<EOF;
<h2>変換結果</h2>
<pre>$result</pre>
EOF
	print "<hr>", html_form();
    } else {
	print html_form();
    }
    print html_foot();
}

sub exec_xslt($$) {
    # 実行性能を上げるために必要な時以外はロードしない。
    require XML::LibXML;
    require XML::LibXSLT;

    my $parser = new XML::LibXML;
    my $xslt_parser = new XML::LibXSLT;

    my $source_doc = $parser->parse_string($xml);
    my $style_doc = $parser->parse_string($xslt);

    my $style_obj = $xslt_parser->parse_stylesheet($style_doc);
    my $result = $style_obj->transform($source_doc);
    return $style_obj->output_string($result);
}

sub read_data ($) {
    my ($fh) = @_;
    my $buf = '';
    my $retstr = '';
    while (read($fh, $buf, 1024)) {
	$retstr .= $buf;
    }
    return $retstr;
}

sub html_foot() {
    my $id = '$Id$';
    my $url = url();
    return <<EOF;
<hr><address>
<a href="$url">$url</a><br>
$id
</address>
</body></html>
EOF
}

sub html_form () {
    $source = escape_html($source);
    $source_f = escape_html($source_f);
    $stylesheet = escape_html($stylesheet);
    $stylesheet_f = escape_html($stylesheet_f);
    return <<EOF;
<form action="xslt-gateway.cgi" method="POST" enctype="multipart/form-data">
<div>
<h2>XML</h2>
<label for="source_f">ファイル: <input type="file" name="source_f" value="$source_f" size="40"></label><br>
<textarea name="source" rows="10" cols="60">$source</textarea>
<h2>XSLTスタイルシート</h2>
<label for="stylesheet_f">ファイル: <input type="file" name="stylesheet_f" value="$stylesheet_f" size="40"></label><br>
<textarea name="stylesheet" rows="10" cols="60">$stylesheet</textarea><br>
<input type="submit" name="submit" value=" 送 信 ">
</div>
</form>
EOF
}

sub escape_html($) {
    my ($str) = @_;
    return undef if not defined $str;
    $str =~ s#&#&amp;#go;
    $str =~ s#<#&lt;#go;
    $str =~ s#>#&gt;#go;
    $str =~ s#"#&quot;#go;
    return $str;
}
