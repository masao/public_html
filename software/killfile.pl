#!/usr/local/bin/perl -w
# $Id$

use strict;
$| = 1;

my $MNEWS_SETUP = "$ENV{'HOME'}/.mnews_setup-news";

main();
sub main {
    my %header;
    my $specify = undef;

    if (defined($ARGV[0])) {
	if ($ARGV[0] =~ /^-(subject|from)/) {
	    $specify = $1;
	} else {
	    usage();
	    exit(1);
	}
    } else {
	usage();
	exit(1);
    }
    
    my @tmp = <STDIN>;
    while (@tmp) {
	my $line = shift @tmp;
	last if ($line =~ /^$/);
	
	while (defined($tmp[0]) && $tmp[0] =~ /^\s+/) {
	    my $nextline = shift @tmp;
	    $nextline =~ s/^s+(.*)$/$1/;
	    $line .= $nextline;
	}
	if ($line =~ /^(\S+):\s*(.*)$/) {
	    $header{lc($1)} = $2;
	}
    }
    open(OUT, ">>$MNEWS_SETUP") ||
	die "can't open config file: $!";

    print OUT "##Newsgroups: $header{'newsgroups'}\n";
    print OUT "##Message-Id: $header{'message-id'}\n";
    print OUT "##Date: $header{'date'}\n";
    print OUT "kill_$specify: $header{$specify}\n";
    print OUT "\n";
    print "# Newsgroups: $header{'newsgroups'}\n";
    print "# Message-Id: $header{'message-id'}\n";
    print "# Date: $header{'date'}\n";
    print "kill_$specify: $header{$specify}\n\n";
    sleep 1;
}

sub usage () {
    print <<EOF;

Usage: $0 [-from|-subject]

EOF
}
