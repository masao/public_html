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

my $q = new CGI;

main();
sub main {
    my @entries = ();
    my $page = $q->param('page') || 0;
    my $start = $page * $MAX;
    my $search = $q->param('search') || "";
    my $sort = $q->param('sort') || 0;

    print <<EOF;
Content-Type: text/html; charset=EUC-JP

<html><head><title>問題と対策 改</title></head><body>
<h1>問題と対策 改</h1>
<p><a href="$ORIG_URL">本家のページ</a></p>
<hr>
<form method="GET" action="$ENV{'SCRIPT_NAME'}">
正規表現:
<input type="text" name="search" value="$search">
<input type="hidden" name="sort" value="$sort">
<input type="submit" value="絞り込み検索">
</form>
EOF

    my $tmp = get($ORIG_URL);
    $tmp =~ s/\s+/ /g;
    $tmp =~ s#<!--(.*?)-->##g;
    $tmp =~ s#<tr>(.+?)</tr>#push(@entries,$1)#geio;

    if (length($search)) {	# 検索
	@entries = grep(/$search/i, @entries);
 	print "<p color=\"red\">", $#entries + 1, "</p>";
	print "件</p>\n";
    }

    print <<EOF;
<hr>
<table width="100%" border="1" bgcolor="$bgcolor">
<tr bgcolor="$bgcolor_head">
<th>項番</th>
<th>問題点</th>
<th>対策状況</th>
<th>発生日</th>
<th>対策日</th>
</tr>
EOF
    for (my $i = $start; $i < $#entries && $i < $start + $MAX; $i++) {
	my @content = ();
	$entries[$i] =~ s#<td>(.+?)</td>#push(@content,$1)#gei;
	print "<tr valign=\"top\">\n";
	foreach my $cont (@content) {
	    $cont =~ s#((https?|ftp)://[;\/?:@&=+\$,A-Za-z0-9\-_.!~*'()]+)#<a href="$1">$1</a>#gi;
	    print "<td>$cont</td>\n";
	}
	print "</tr>\n";
    }
    print "</table>\n";
    print "<div>ページ:\n";
    for (my $i = 0; $i*$MAX < $#entries; $i++) {
	print "<a href=\"$ENV{'SCRIPT_NAME'}?page=$i\">", $i+1, "</a>\n";
    }
    print "</div>\n";
    # print $content;
    print <<EOF;
</body></html>
EOF
}
