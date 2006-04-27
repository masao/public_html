#!/usr/bin/env perl
# $Id$

use strict;
use warnings;

use ChangeLogReader;

my $cl = ChangeLogReader->new( use_category => 0 );
foreach my $file (@ARGV) {
    $cl->store_changelog_file($file);
}

my $cl_new = ChangeLogReader->new;
foreach my $ymd (reverse sort keys %{$cl->{all}}) {
    my $ent = $cl->{all}->{$ymd};
    print $ymd,"  ",$ent->{"1"}->{a},"\n\n";
    for (my $i = $ent->{curid}; $i >= 1; $i--) {
	if ($ent->{$i}->{ho} =~ s/\s*\[pub\]\s*//o) {
	    my $header = $ent->{$i}->{ho};
	    my $cont = $ent->{$i}->{co};
	    $cont =~ s/^/\t/gm;
	    print "\t* $header:\n";
	    print "$cont\n";
	}
    }
}

