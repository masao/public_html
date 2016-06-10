#!/usr/bin/env perl
my $fn = shift @ARGV;
print "Content-type: text/plain; charset=euc-jp\n\n";
die if ($fn =~ /[\s\x00-\x1f]/);
$fn =~ s{[^a-zA-Z0-9\.\-\#_/]}{_}g;
$fn =~ s/\.\.//g;
$fn =~ s|^/||g;
if (-e $fn) {
    open(F, $fn);
    print <F>;
    close(F);
}
