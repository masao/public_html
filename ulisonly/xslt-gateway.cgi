#!/usr/local/bin/perl -w
# -*- CPerl -*-
# $Id$

use strict;
use CGI qw/:cgi/;
use CGI::Carp qw(fatalsToBrowser);

### ����ѿ�

my $TITLE = 'XSLT �����ȥ�����';
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
<p>XML��XSLT�����Ϥ���ȡ��Ѵ���̤��ǧ�Ǥ��ޤ���</p>
<p><strong>���:</strong></p>
<ul>
<li>�ե�������������ͥ�褵��ޤ����ե�������ꤷ�ʤ����ϡ��ƥ����ȥ��ꥢ�����Ƥ��Ȥ��ޤ���
<li>�ƥ����ȥ��ꥢ�Ǥ� XML ����ϡ�ɬ��<code>encoding="EUC-JP"</code>��ȤäƤ���������
<li>XSLT���<code>&lt;xsl:output encoding="EUC-JP"&gt;</code>�Ȥ��ʤ��ȡ����ܸ�ʤɤ�ʸ���������Ƥ��ޤ��ޤ���
</ul>
<hr>
EOF

my $DEFAULT_SOURCE = <<EOF;
<?xml version="1.0" encoding="EUC-JP"?>
<�ۤ�>
�դ��դ�
</�ۤ�>
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

### CGI ����
my $display = param('display') || 'preview';
my $source = param('source') || $DEFAULT_SOURCE;
my $source_f = param('source_f') || '';
my $stylesheet = param('stylesheet') || $DEFAULT_STYLESHEET;
my $stylesheet_f = param('stylesheet_f') || '';

my $xml = length(param("source_f")) ? read_data($source_f) : $source;
my $xslt = length(param("stylesheet_f")) ? read_data($stylesheet_f) : $stylesheet;

main();
sub main {
    if (defined param('submit')) {
	my ($type, $result) = exec_xslt();
	if ($display eq 'preview') {
	    print header("text/html; charset=EUC-JP");
	    print $HTML_HEAD;
	    $result = escape_html($result);
	    print <<EOF;
<h2>�Ѵ����</h2>
<pre style="border: solid thin; padding: 2px;">$result</pre>
EOF
	    print "<hr>", html_form();
	    print html_foot();
	} else {
	    print header($type);
	    print $result;
	}
    } else {
	print header("text/html; charset=EUC-JP");
	print $HTML_HEAD;
	print html_form();
	print html_foot();
    }
}

sub exec_xslt($$) {
    require XML::LibXML;  # �¹���ǽ��夲�뤿���ɬ�פʻ��ʳ��ϥ��ɤ��ʤ���
    require XML::LibXSLT;

    my $parser = new XML::LibXML;
    my $xslt_parser = new XML::LibXSLT;

    my $source_doc = $parser->parse_string($xml);
    my $style_doc = $parser->parse_string($xslt);

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
    $source_f = escape_html($source_f);
    $stylesheet = escape_html($stylesheet);
    $stylesheet_f = escape_html($stylesheet_f);
    return <<EOF;
<form action="xslt-gateway.cgi" method="POST" enctype="multipart/form-data">
<div>
<h2>XML</h2>
<label for="source_f">�ե�����: <input type="file" name="source_f" id="source_f" value="$source_f" size="40"></label><br>
<textarea name="source" rows="10" cols="60">$source</textarea>
<h2>XSLT�������륷����</h2>
<label for="stylesheet_f">�ե�����: <input type="file" name="stylesheet_f" id="stylesheet_f" value="$stylesheet_f" size="40"></label><br>
<textarea name="stylesheet" rows="10" cols="60">$stylesheet</textarea><br>
<fieldset><legend>ɽ������</legend>
<label><input type="radio" name="display" value="preview" checked>�Ѵ���̤Υ�������ץ�ӥ塼ɽ������</label><br>
<label><input type="radio" name="display" value="raw">�Ѵ���̤Τߤ򤽤Τޤ�ɽ������</label>
</fieldset>
<input type="submit" name="submit" value=" �� �� ">
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
