#!/usr/local/bin/perl -w
# $Id$

use Pod::POM;
use strict;

# create custom view
package Mypage::View;
use base qw( Pod::POM::View::HTML );

sub view_pod {
    my ($self, $pod) = @_;
    my $title = $pod->head1->[0]->content;
    my $home = 'http://nile.ulis.ac.jp/~masao/';
    my $email = 'masao@ulis.ac.jp';
    my $header = <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../../default.css" type="text/css">
<link rev="made" href="mailto:$email">
<title>$title</title>
</head>
<body>
<div><a href="./">[Up]</a></div><hr>
<h1>$title</h1>
EOF
    my $footer = <<EOF;
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="$home">$home</a>,
<a href="mailto:$email">$email</a>
</address>
</body></html>
EOF
    return $header
        . $pod->content->present($self)
        . $footer;
}

sub view_head1 {
    my ($self, $item) = @_;
    return "<h2>"
	. $item->title->present($self)
	. "</h2>\n"
	. $item->content->present($self);
}

sub view_head2 {
    my ($self, $item) = @_;
    return "<h3>"
	. $item->title->present($self)
	. "</h3>\n"
	. $item->content->present($self);
}

package main;

my $file = $ARGV[0] || usage();
my $parser = Pod::POM->new( warn => 1 )
    || die "$Pod::POM::ERROR\n";
my $pom = $parser->parse_file($file)
    || die $parser->error(), "\n";

print Mypage::View->print($pom);

sub usage() {
    print "  USAGE: $0 file\n";
    exit;
}
