#!/usr/local/bin/perl -w
# $Id$
#
#  Copyright (C) 2001 Masao Takaku <tmasao@acm.org>.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# This file must be encoded in EUC-JP.

use strict;
use FileHandle;
use URI;
use File::Basename;
use File::Path;

$| = 1;
$URI::ABS_REMOTE_LEADING_DOTS = 1;

my $LEVEL = 0;	# 何レベル、再帰的に取得する?

my $OUTDIR = "./";	# ファイルを出力するディレクトリ

my $DEBUG = 0;

my @UNREAD = ();	# まだ読んでないURIを登録する
my %FINISH = ();	# 取得済URIを登録する

my $original_uri = undef;	# 最初に指定されたURI

my $google_prefix = 'http://www.google.com/search?q=cache:';

main();
sub main {
    $original_uri = URI->new(parse_options());
    my $level = 0;
    push @UNREAD, $original_uri, $level;
    chdir($OUTDIR) || die "$OUTDIR: $!";

    $original_uri =~ s#([^/]+)$##;
    while (my ($uri, $level) = @UNREAD) {
	shift @UNREAD; shift @UNREAD;
	next if (exists($FINISH{$uri->canonical}));

	$FINISH{$uri->canonical} = 1;
	print " " x $level;
	print "$uri -> ";
	$level++;

	my $cont = get_google_data($uri);
	if (!defined($cont)) {
	    # キャッシュに見つからない…。
	    print "ERROR!\n";
	    print "Not exist $uri in Google's cache.\n";
	    # print "\t$google_prefix$uri\n";
	    # print "\n$google_str\n";
	    next;
	}

	# ファイルに書き出す。
	my $file = local_filename($uri);
	open (FILE, "> $file") || die "can't write $file: $!";
	print FILE $cont;
	close (FILE);

	# さらなるリンクを探す
	$cont =~ s#\s+##g;
	$cont =~ s/href=([\"\']?)([^\>]+?)\1/register_uri($2, $uri, $level)/gei;
	sleep 1;
    }
}

sub parse_options() {
    while (defined($ARGV[0]) && $ARGV[0] =~ /^-/) {
	if ($ARGV[0] =~ /^-l/) {	# レベルを指定
	    shift @ARGV;
	    $LEVEL = shift @ARGV;
	} elsif ($ARGV[0] =~ /^-O/) {
	    shift @ARGV;
	    $OUTDIR = shift @ARGV;
	} elsif ($ARGV[0] =~ /^-d/) {
	    shift @ARGV;
	    $DEBUG = 1;
	} else {
	    print "Unknown option: $ARGV[0]\n";
	    usage();
	    exit(-1);
	}
    }
    if (!defined($ARGV[0])) {
	usage();
	exit (-1);
    }
    return $ARGV[0];
}

sub usage() {
    	print <<EOF;
Usage:  $0 [options] URI

Options:
    -l NUM	Specify recursive level. (default: 0)
    -O DIR	Set Output directory. (default: current directory)
    -d		Set debug mode.

EOF

}

# ローカル上のファイル名を推定する。
sub local_filename($) {
    my ($file) = @_;

    $file =~ s#/$#/index.html#;
    $file =~ s#^$original_uri##;
#      if ($uri =~ m#^(.*/)$#) {
#  	$file = "$1index.html";
#      } elsif ($uri =~ m#(.*)/([^/]+)$#) {
#  	$file = $2;
#      } else {
#  	die "local_filename: $uri -> $file\n";
#      }
    my $dir = dirname($file);
    if (-f $file) {
	for my $i (1 ... 20) {
	    if (! -f "$file.$i") {
		$file = "$file.$i";
		last;
	    }
	}
    } elsif (! -d $dir) {
	mkpath($dir);
    }
    print "$file\n";
    return $file;
}

sub register_uri($$$) {
    my ($str, $parent_uri, $current_level) = @_;
    $str =~ s/(#.*)$//;
    my $uri = URI->new_abs($str, $parent_uri);
    if (!exists($FINISH{$uri->canonical}) &&
	$uri =~ /^$original_uri/ &&
	$current_level <= $LEVEL) {

	push @UNREAD, $uri, $current_level;
	print "register: $uri\n" if $DEBUG;
    }
}

sub get_google_data($) {
    my ($uri) = @_;
    my $tmpfile = "/tmp/google.$$";

    if ($uri =~ m#^http://#) {
	$uri =~ s#http://##;
    }
    system "wget -O $tmpfile \"$google_prefix$uri\" 1>/dev/null 2>&1";
    my $cont = readfile($tmpfile);
    unlink($tmpfile);

    # 先頭3行捨てる。
    my @tmp = split(/\n/, $cont);
    my $google_str = shift @tmp;
    $google_str .= shift @tmp;
    $google_str .= shift @tmp;
    $cont = join("\n", @tmp);
    if ($google_str =~ m#<title>#i ) {
	$cont = undef;
    }
    return $cont;
}

sub readfile($) {
    my ($fname) = @_;

    my $fh = new FileHandle;
    $fh->open($fname) || die "$fname: $!";

    my $cont = '';
    my $size = -s $fh;
    read $fh, $cont, $size;

    $fh->close();
    return $cont;
}
