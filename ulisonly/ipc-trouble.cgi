#!/usr/local/bin/perl -wT
# -*- CPerl -*-
# $Id$

use strict;
use CGI;
use LWP::Simple;

my $ORIG_URL = 'http://www.ulis.ac.jp/ipc/main2002/troublelist.html';
my $MAX = 10;

# テーブル全体の背景色
my $bgcolor = '#ddddd0';

# テーブルヘッダの背景色
my $bgcolor_head = '#00A020';

my @TABLE_LABEL = ('項番', '問題点', '対策状況', '発生日', '対策日');

my $q = new CGI;
my $page = escape_html($q->param('page')) || 0;
my $search = escape_html($q->param('search')) || "";
my $sort = escape_html($q->param('sort')) || 0;

my @problems = ();

main();
sub main {
    my @entries = ();

    print $q->header('text/html; charset=EUC-JP');
    print <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja"><head><title>問題と対策 改</title></head><body>
<h1>問題と対策 改</h1>
<p><a href="$ORIG_URL">（本家のページ）</a></p>
<hr>
<form method="GET" action="$ENV{'SCRIPT_NAME'}">
<p>正規表現:
<input type="text" name="search" value="$search">
<input type="hidden" name="sort" value="$sort">
<input type="submit" value="絞り込み検索">
</p>
</form>
EOF

    my $tmp = get($ORIG_URL);
    $tmp =~ s/\s+/ /g;
    $tmp =~ s#<!--(.*?)-->##g;
    $tmp =~ s#<tr>(.+?)</tr>#push(@entries,$1)#geio;

    if (length($search)) {	# 検索
	@entries = grep(/$search/i, @entries);
 	print "<p><font color=\"red\">検索結果: ", $#entries + 1, "件</font></p>\n";
    }

    foreach my $cont (@entries) {
	my @tmp = ();
	$cont =~ s#<td>(.+?)</td>#push(@tmp,$1)#gei;
	push(@problems, \@tmp);
    }
    @problems = sort { fncmp($a->[$sort], $b->[$sort]) } @problems;

    print <<EOF;
<hr>
<table width="100%" border="1" bgcolor="$bgcolor">
<tr bgcolor="$bgcolor_head">
EOF
    for (my $i = 0; $i < @TABLE_LABEL; $i++) {
	print "<th><a href=\"$ENV{'SCRIPT_NAME'}?sort=$i;search=$search\">$TABLE_LABEL[$i]</a></th>\n";
    }
    print "</tr>\n";

    for (my $i = $page * $MAX; $i < @problems && $i < ($page+1) * $MAX; $i++) {
	print "<tr valign=\"top\">\n";
	foreach my $cont (@{$problems[$i]}) {
	    $cont =~ s#((https?|ftp)://[;\/?:@&=+\$,A-Za-z0-9\-_.!~*'()]+)#<a href="$1">$1</a>#gi;
	    print "<td>$cont</td>\n";
	}
	print "</tr>\n";
    }
    print "</table>\n";
    print_pages();
    print <<EOF;
</body></html>
EOF
}

# 数字を考慮したソート
sub fncmp() {
    my ($x, $y) = @_;
    $x =~ s/(\d+)/sprintf("%05d", $1)/ge;
    $y =~ s/(\d+)/sprintf("%05d", $1)/ge;
    return $x cmp $y;
}

sub print_pages() {
    my $base_url = "$ENV{'SCRIPT_NAME'}?sort=$sort;search=$search";
    print "<p>ページ:\n";
    for (my $i = 0; $i*$MAX < @problems; $i++) {
	if ($i == $page) {
	    print $i+1, "\n";
	} else {
	    print "<a href=\"$base_url;page=$i\">", $i+1, "</a>\n";
	}
    }
    print "</p>\n";
}

sub escape_html($) {
    my ($str) = @_;
    return undef if not defined $str;
    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/"/&quot;/g;
    return $str;
}
