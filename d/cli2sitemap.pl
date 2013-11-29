#!/usr/bin/perl

use strict;
use warnings;
use Class::Date qw( now date );

my $BASEURI = "http://masao.jpn.org/d/";

my %PRIORITY = (
     7 => 0.6, # month
     10 => 0.8,# day
     12 => 1.0,# item
    );

my %hash;
while (<>) {
    if (/^<a href=\"([\d\-]+).html/) {
	my $f = $1;
	$hash{ $f } = 1;
	$hash{ substr($f, 0, 7) } = 1;
	$hash{ substr($f, 0, 10) } = 1 if length($f) > 7;
    }
}

my $today = now;
my $xml;
foreach (reverse sort keys %hash) {
    my $p = $PRIORITY{ length($_) };
    my $freq;
    my @tmp = split(/-/, $_);
    my $reldate = $today - date[ @tmp ];
    #print join(" ", @tmp),"\n";
    if ($reldate->day > 365) {
	$freq = "yearly";
    } elsif ($reldate->day > 31) {
	$freq = "monthly";
    } elsif ($reldate->day > 7) {
	$freq = "weekly";
    } elsif ($reldate->day > 1) {
	$freq = "daily";
    } else {
	$freq = "hourly";
    }
    $xml .= <<URL;
   <url>
      <loc>$BASEURI$_.html</loc>
      <changefreq>$freq</changefreq>
      <priority>$p</priority>
   </url>
URL
}

print <<XML;
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
   <url>
      <loc>$BASEURI</loc>
      <changefreq>daily</changefreq>
      <priority>0.8</priority>
   </url>
$xml
</urlset>
XML
