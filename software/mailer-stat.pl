#! /usr/local/bin/perl -w
# $Id$

use strict;
use File::Find;

my %COUNT = ();
my $VERSION_REGEXP = '([vV]|[vV]er|[vV]ersion|[rR]|[rR]elease|pre|b|rc)?[ .]*[0-9][0-9.\-\/\#]*';

main();
sub main {
    if (!defined($ARGV[0])) {
	print "Usage:  $0 dir ...\n";
	exit;
    }

    my $wanted = sub {
	# my $file = "$File::Find::dir/$_";
	if (-f && /^\d+$/) {
	    # print "$_\n";
	    open(FILE, $_) || die "open fail: $!";
	    while (my $line = <FILE>) {
		if ($line =~ /^(X-Mailer|User-Agent|X-Newsreader):\s*(.*)$/) {
		    my $mailer = $2;

		    $mailer =~ s/\([^)]*\)/ /g;
		    $mailer =~ s/\[[^\]]*\]/ /g;
		    $mailer =~ s/\"[^\"]*\"/ /g;

		    $mailer =~ s/$VERSION_REGEXP.*$//g;
		    $mailer =~ s/\b(under|on|for)\b.*$//g;
		    $mailer =~ s/[\/,.].*$//g;

		    $mailer =~ s/\s+/ /g;
		    $mailer =~ s/^\s+//g;
		    $mailer =~ s/\s+$//g;
		    
		    $COUNT{$mailer}++;
		    last;
		} elsif ($line =~ /^$/) {
		    $COUNT{'Unknown'}++;
		    last;
		}
	    }
	}
    };

    find($wanted, @ARGV);

    foreach my $mailer (sort { $COUNT{$b} <=> $COUNT{$a} } keys %COUNT) {
	print "$COUNT{$mailer}\t$mailer\n";
    }
}
