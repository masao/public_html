#!/usr/local/bin/perl -w
# $Id$

# File::MMagic �����Ѥ��ƥե����������Ƚ�ꤹ�륳�ޥ��:

use strict;
use File::MMagic;

my $magic = File::MMagic->new();

foreach my $f (@ARGV) {
    my $type = $magic->checktype_filename($f);
    print "$f:\t$type\n";
}
