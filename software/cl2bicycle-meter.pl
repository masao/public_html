#!/usr/bin/env perl
# $Id$

use strict;
use warnings;

use ChangeLogReader;
use Data::Dumper;

my $cl = ChangeLogReader->new();
for my $fname (@ARGV) {
    $cl->store_changelog_file($fname);
}
my @cycle_entries;
my $dist_total = 0;
foreach my $ymd (sort keys %{$cl->{all}}) {
    # print Dumper(\%{$cl->{all}->{$ymd}});
    my $entry = $cl->{all}->{$ymd};
    for (my $i = $entry->{curid}; $i >= 1; $i--) {
	if ($entry->{$i}->{ho} eq '今日のサイクリング') {
	    my $cont = $entry->{$i}->{co};
	    #print join( "\t", "<$ymd>", $cont );
	    my $dist = $1 if $cont =~ /距離:\s*([\d\.]+)\s*km/iso;
	    my $time = $1 if $cont =~ /時間:\s*([\d\.\:]+)/iso;
	    $dist_total += $dist;
	    $time = "0:".$time if not defined((split(/:/, $time))[2]);
	    print join( "\t", $ymd, $dist, $time, $dist_total ), "\n";
	    #push( @cycle_entries, $entry );
	}
    }
}
