#!/usr/local/bin/perl -w
# $Id$

# 日本語版 MS PowerPoint が生成するファイル名を
# （Unix上などで扱いやすいように）変更する。
#   「スライド1.GIF」→「001.gif」

### Usage: rename_ppt_imgs.pl [-n]

use strict;

# 半角カナ: "\x8e\x57\x8e\x44\x8e\x5e";
# 全角カナ: "\x83\x58\x83\x89\x83\x43\x83\x68";
my $SURAIDO = "(\x83\x58\x83\x89\x83\x43\x83\x68|\x8e\x57\x8e\x44\x8e\x5e)";

my $NOCHANGE = 0;

while (defined $ARGV[0]) {
    my $opt = shift @ARGV;
    if ($opt eq "-n") {
	$NOCHANGE = 1;
    }
}

opendir(DIR, ".") || die "opendir fail: $!";
my @file = readdir(DIR);
foreach my $f (@file) {
    if ($f =~ /^$SURAIDO/) {
	my $newname = $f;
	$newname =~ s/^$SURAIDO//;
	$newname =~ s/(\.\w+)$/lc($1)/e;
	$newname =~ s/(\d+)/sprintf("%03d", $1)/e;
	unless ($NOCHANGE) {
	    rename($f, $newname) || die "rename failed: $!";
	}
	print escape($f) ." -> ". escape($newname) ."\n";
    }
}

sub escape($) {
    my ($str) = @_;
    $str =~s/([^a-zA-Z0-9_.-])/sprintf("\\%03o",ord($1))/eg;
    return $str;
}
