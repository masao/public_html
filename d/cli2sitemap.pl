#!/usr/bin/perl

use strict;
use warnings;
use Class::Date qw( now date );

my $BASEURI = "http://masao.jpn.org/d/";

my %hash;
while (<>) {
    $hash{$1} = $hash{$2} = $hash{$3} = 1
if (/^<a href=\"(((\d+-\d+)-\d+)-\d+)/);
}

my $today = now;
my $xml;
foreach (sort keys %hash) {
    my $p = (length($_) == 7) ? 0.4 : ((length($_) == 10) ? 0.6 : "1.0");
    my $freq;
    my $reldate = $today - date $_;
    if ($reldate->day > 31) {
	$freq = "monthly";
    } elsif ($reldate->day > 7) {
	$freq = "weekly";
    } elsif ($reldate->day > 1) {
	$freq = "daily";
    } else {
	$freq = "hourly";
    }
    $xml .= << "URL"
   <url>
      <loc>$BASEURI$_.html</loc>
      <changefreq>$freq</changefreq>
      <priority>$p</priority>
   </url>
URL
}

print << "XML"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.google.com/schemas/sitemap/0.84">
   <url>
      <loc>$BASEURI</loc>
      <changefreq>daily</changefreq>
      <priority>0.8</priority>
   </url>
$xml
</urlset>
XML
