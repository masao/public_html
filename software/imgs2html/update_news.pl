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

    my $latest = get_latest("../archive", "imgs2html");
    print "Latest: $latest\n";

    my $news = news2html($NEWSFILE);

    $cont = subst_all($cont, "NEWS", $news);
    $cont = subst_all($cont, "LATEST", "<a href=\"../archive/$latest\">$latest</a>");

    rename($HTML, "$HTML.bak") || die "rename error: $!";
    open(HTML, "> $HTML") || die "$HTML: $!";
    print HTML $cont;
}

sub subst_all($$$) {
    my ($src, $context, $subst) = @_;
    $src =~ s#(<!-- $context -->)(.*?)(<!-- $context -->)#$1\n$subst\n$3#gs;
    return $src;
}

sub get_latest($$) {
    my ($dir, $prefix) = @_;
    opendir(D, $dir) || die "opendir error: $dir: $!";
    my @files = grep(/^$prefix/i, readdir(D));
    @files =  map  { $_->[0] }
	      sort { $b->[1] cmp $a->[1] }
	      map  { my $tmp = $_; $tmp =~ s/(\d+)/sprintf("%08d", $1)/ge;
		     [ $_, $tmp ] } @files;
    return $files[0];
}

sub news2html($) {
    my ($file) = @_;
    my $ret = "<ul>\n";
    open(NEWS, $file) || die "$file: $!";
    while (my $line = <NEWS>) {
	chomp($line);
	if ($line =~ /^\[(\S+)\]\s*\(([\d\-]+)\)/) {
	    $ret .= "<li><strong>$2</strong>: Version $1 を公開<ul>\n";
	} elsif ($line =~ s/^\s+//) {
	    $line =~ s/\*/<li>/;
	    $ret .= "$line\n";
	} elsif ($line =~ /^$/) {
	    $ret .= "</ul>\n";
	}
    }
    $ret .= "</ul>\n";
    return $ret;
}
