#!/usr/local/bin/perl -w
# $Id$

# NEWS を index.html に反映させる。

use strict;
main();
sub main {
    my $NEWSFILE = '/home/masao/CVSwork/imgs2html/NEWS';
    my $HTML = 'index.html';

    open(IN, $HTML) || die "$HTML: $!";
    my @tmp = <IN>;
    close IN;
    my $cont = join('', @tmp);

    my $news = news2html($NEWSFILE);
    $cont =~ s#(<!-- NEWS -->)(.*)(<!-- NEWS -->)#$1\n$news\n$3#gs;

    open(HTML, "> $HTML") || die "$HTML: $!";
    print HTML $cont;
}

sub news2html($) {
    my ($file) = @_;
    my $ret = "<dl>\n";
    open(NEWS, $file) || die "$file: $!";
    while (my $line = <NEWS>) {
	chomp($line);
	if ($line =~ /^\[(\S+)\]\s*\(([\d\-]+)\)/) {
	    $ret .= "<dt>$2: Version $1 を公開<dd><ul>\n";
	} elsif ($line =~ s/^\s+//) {
	    $line =~ s/\*/<li>/;
	    $ret .= "$line\n";
	} elsif ($line =~ /^$/) {
	    $ret .= "</ul>\n";
	}
    }
    $ret .= "</dl>\n";
    return $ret;
}
