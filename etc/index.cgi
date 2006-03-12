#!/usr/local/bin/perl -wT
# $Id$

use strict;
use Jcode;
use CGI;

my $q = new CGI;
print $q->header;

print <<'EOF';
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev="made" href="mailto:masao@nii.ac.jp">
<title>たかくまさおのその他のページ</title>
</head>

<body>
<p>
雑多な覚え書きその他を置いてあります。
</p>
<ul>
EOF

my @files = ();
open(F, "CVS/Entries") || die "open fail: Entries: $!";
while (defined(my $line = <F>)) {
    push @files, (split(/\//, $line))[1];
}

for my $file (sort { mtime($b) <=> mtime($a) } @files) {
    print "<li><a href=\"$file\">", get_html_title($file),
	  "</a> [",  iso8601(mtime($file)), "]\n"
	if defined($file) && $file =~ /\.html$/;
}

print <<'EOF';
</ul>
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="http://masao.jpn.org/">http://masao.jpn.org/</a>, 
<a href="mailto:masao@nii.ac.jp">masao@nii.ac.jp</a>
</address>
</body>
</html>
EOF

sub mtime($) {
    my ($fname) = @_;
    return (stat($fname))[9];
}

sub iso8601($) {
    my ($time) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
	localtime($time);
    $year += 1900;
    $mon += 1;
    return sprintf("%04d-%02d-%02d", $year, $mon, $mday);
}

sub get_html_title($) {
    my ($file) = @_;
    open(HTML, $file) || die "open fail: $file: $!";
    my @tmp = <HTML>;
    my $cont = join('', @tmp);
    $cont = Jcode->new($cont)->euc;
    my ($title) = $cont =~ m#<title>([^<]*)</title>#io;
    return $file if not defined $title;
    return $title;
}
