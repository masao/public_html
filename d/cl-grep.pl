#!/usr/bin/env perl
# $Id$

use strict;
use warnings;

use ChangeLogReader;

my $cl = ChangeLogReader->new;
foreach my $file (@ARGV) {
    $cl->store_changelog_file($file);
}

my $cl_new = ChangeLogReader->new;
foreach my $ymd (reverse sort keys %{$cl->{all}}) {
    print "$ymd\n";
    my $ent = $cl->{all}->{$ymd};
    for (my $i = $ent->{curid}; $i >= 1; $i--) {
	if ($ent->{$i}->{ho} =~ s/\s*\[pub\]\s*//o) {
	    my $header = $ent->{$i}->{ho};
	    my $cont = $ent->{$i}->{co};
	    $cont =~ s/^/\t/gm;
	    print "\t* $header\n";
	    print "$cont\n";
	}
    }
}

