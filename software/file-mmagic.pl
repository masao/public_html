#!/usr/local/bin/perl -w
# $Id$

# File::MMagic を利用してファイル形式を判定するコマンド:

use strict;
use File::MMagic;

my $magic = File::MMagic->new();

foreach my $f (@ARGV) {
    my $type = $magic->checktype_filename($f);
    print "$f:\t$type\n";
}
