#!/usr/bin/env perl
# $Id$

use strict;
use warnings;

use ChangeLogReader;
use Data::Dumper;

sub time_parse($) {
    my ($time) = @_;
    my ($hh, $mm) = split( /:/, $time );
    my $minutes = $hh * 60 + $mm;
    #print "$time => $minutes\n";
    return $minutes;
}

my $cl = ChangeLogReader->new();
for my $fname (@ARGV) {
    $cl->store_changelog_file($fname);
}
my $time_total = 0;
foreach my $ymd (sort keys %{$cl->{all}}) {
    my $minutes = 0;
    my $entry = $cl->{all}->{$ymd};
    for (my $i = $entry->{curid}; $i >= 1; $i--) {
	if ($entry->{$i}->{ho} eq '研究') {
	    my $cont = $entry->{$i}->{co};
	    if ( $cont =~ /\s*\[([\d\:\,\s\-]+)\]/o ) {
		#print $1,"\n";
		my @times = split( /,\s*/, $1 );
		foreach my $time ( @times ) {
		    my ( $start, $end ) = split( /\s*\-\s*/, $time );
		    $minutes += time_parse( $end ) - time_parse( $start );
		}
	    }
	    next if $minutes == 0;
	    $time_total += $minutes;
	    print join( "\t", $ymd, $minutes, $time_total ), "\n";
	}
    }
}
