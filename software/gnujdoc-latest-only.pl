#!/usr/local/bin/perl -w
# $Id$

use strict;

$| = 1;

my $CONFIG = "configure.in";
my %Soft = ();
my %Opt = ();
my $Disable = '';

main();
sub main {
    open(CONF, $CONFIG) || die "$CONFIG: $!";
    my @tmp = <CONF>;
    close(CONF);
    foreach my $line (@tmp) {
	if ($line =~ /^gnujdoc_CHECK_SUBDIR\(gnujdoc_subdir_([^,]+),([^)]+)\)$/) {
	    my $dir = $2;
	    my $opt = $1;
	    adddir($dir, $opt);
	}
    }
    my $cmd = "./configure $Disable";
    print $cmd, "\n";
    system($cmd);
}

sub adddir($$) {
    my ($dir, $opt) = (@_);
    my $name = get_name($dir);
    my $ver = get_version($dir);
    if (defined($Soft{$name})) {
	if (!vcmp($ver, get_version($Soft{$name}))) {
	    $Disable .= " --disable-$Opt{$name}";
	    $Soft{$name} = $dir;
	    $Opt{$name} = $opt;
	    print $dir, "\n";
	    return;
	}
    }
    $Soft{$name} = $dir;
    $Opt{$name} = $opt;
}

sub get_name($) {
    my ($dir) = (@_);
    $dir =~ /^([a-zA-Z]+)/;
    return $1;
}

sub get_version($) {
    my ($dir) = (@_);
    $dir =~ /([0-9]\.]+)$/;
    return $1;
}

sub vcmp($$) {
    my ($x, $y) = (@_);
    $x =~ s/(\d+)/sprintf("%08d", $1)/ge;
    $y =~ s/(\d+)/sprintf("%08d", $1)/ge;
    $x cmp $y;
}

