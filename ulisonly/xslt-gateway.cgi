#!/usr/local/bin/perl -wT
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
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev=made href="mailto:$FROM">
<title>$TITLE</title>
</head>
<body>
<h1>$TITLE</h1>
<p><a href="http://www.w3.org/TR/1998/REC-xml-19980210"><acronym title="Extensible Markup Language">XML</acronym></a>文書に対して<a href="http://www.w3.org/TR/1999/REC-xslt-19991116"><acronym title="XSL Transformations">XSLT</acronym></a>を適用した変換結果を確認できます。</p>
<p><strong>注意:</strong></p>
<ul>
<li>ファイル指定の方が優先されます。ファイル指定しない場合は、テキストエリアの内容が使われます。
</ul>
<hr>
EOF

my $DEFAULT_SOURCE = <<EOF;
<?xml version="1.0"?>
<ほげ>
ふがふが
</ほげ>
EOF

my $DEFAULT_STYLESHEET = <<EOF;
<?xml version="1.0"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns="http://www.w3.org/1999/xhtml"
               version="1.0">
<xsl:output method="html"/>

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
my $display = param('display') || 'preview';

my $source = param('source') || $DEFAULT_SOURCE;
$source = read_data(param('source_f'))
    if defined param('source_f') && length param('source_f');

my $stylesheet = param('stylesheet') || $DEFAULT_STYLESHEET;
$stylesheet = read_data(param('stylesheet_f'))
    if defined param('stylesheet_f') && length param('stylesheet_f');

main();
sub main {
    if (defined param('submit')) {
	my ($type, $result) = exec_xslt();
	if ($display eq 'preview') {
	    print header("text/html; charset=UTF-8");
	    print $HTML_HEAD;
	    $result = escape_html($result);
	    print <<EOF;
<h2>変換結果</h2>
<pre style="border: solid thin; padding: 2px;">$result</pre>
EOF
	    print "<hr>", html_form();
	    print html_foot();
	} else {
	    print header($type);
	    print $result;
	}
    } else {
	print header("text/html; charset=UTF-8");
	print $HTML_HEAD;
	print html_form();
	print html_foot();
    }
}

sub exec_xslt() {
    require XML::LibXML;  # 実行性能を上げるために必要な時以外はロードしない。
    require XML::LibXSLT;

    my $parser = new XML::LibXML;
    my $xslt_parser = new XML::LibXSLT;

    my $source_doc = $parser->parse_string($source);
    my $style_doc = $parser->parse_string($stylesheet);

    my $style_obj = $xslt_parser->parse_stylesheet($style_doc);
    my $type = $style_obj->media_type();
    my $result = $style_obj->transform($source_doc);

    return ($type, $style_obj->output_string($result));
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
    $stylesheet = escape_html($stylesheet);
    return <<EOF;
<form action="xslt-gateway.cgi" method="POST" enctype="multipart/form-data">
<div>
<h2>XML</h2>
<label for="source_f">ファイル:
<input type="file" name="source_f" id="source_f" value="" size="40"></label><br>
<textarea name="source" rows="10" cols="60">$source</textarea>
<h2>XSLTスタイルシート</h2>
<label for="stylesheet_f">ファイル: <input type="file" name="stylesheet_f" id="stylesheet_f" value="" size="40"></label><br>
<textarea name="stylesheet" rows="10" cols="60">$stylesheet</textarea><br>
<fieldset><legend>表示方式</legend>
<label><input type="radio" name="display" value="preview" checked>変換結果のソースをプレビュー表示する</label><br>
<label><input type="radio" name="display" value="raw">変換結果をそのまま表示する</label>
</fieldset>
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
