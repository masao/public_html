#!/usr/local/bin/perl -w
# $Id$

# ���ܸ��� MS PowerPoint ����������ե�����̾��
# ��Unix��ʤɤǰ����䤹���褦�ˡ��ѹ����롣
#   �֥��饤��1.GIF�ע���001.gif��

use strict;

# Ⱦ�ѥ���: "\x8e\x57\x8e\x44\x8e\x5e";
# ���ѥ���: "\x83\x58\x83\x89\x83\x43\x83\x68";
my $SURAIDO = "(\x83\x58\x83\x89\x83\x43\x83\x68|\x8e\x57\x8e\x44\x8e\x5e)";

opendir(DIR, ".") || die "opendir fail: $!";
my @file = readdir(DIR);
foreach my $f (@file) {
    if ($f =~ /^$SURAIDO/) {
	my $newname = $f;
	$newname =~ s/^$SURAIDO//;
	$newname =~ s/(\.\w+)$/lc($1)/e;
	$newname =~ s/(\d+)/sprintf("%03d", $1)/e;
	print "rename to $newname\n";
	rename($f, $newname) || die "rename failed: $!";
    }
}
