#!/usr/local/bin/perl -wT
# -*- CPerl -*-
# $Id$

use strict;
use CGI;
use CGI::Carp 'fatalsToBrowser';
use LWP::UserAgent;
use HTTP::Request;

# 本家のURL
my $ORIG_URL = 'http://www.ulis.ac.jp/ipc/main2002/troublelist.shtml';

# タイトル
my $TITLE = '「問題と対策」改';

# 1ページに表示する件数
my $MAX = 10;

# テーブル全体の背景色
my $bgcolor = '#ddddd0';

# テーブルヘッダの背景色
my $bgcolor_head = '#00A020';

# メールアドレス
my $address = 'masao@ulis.ac.jp';

# 項目のラベル
my @TABLE_LABEL = ('項番', '問題点', '対策状況', '発生日', '対策日');

# CGIパラメータ
my $q = new CGI;
my $SCRIPT_NAME = $q->script_name();
my $page = escape_html($q->param('page')) || 0;
my $search = escape_html($q->param('search')) || "";
my $sort = escape_html($q->param('sort')) || 0;

### 各項目を入れる作業用の配列
my @problems = ();

main();
sub main {
    print $q->header('text/html; charset=EUC-JP');
    print_html_head();

    my @entries = get_contents();

    print <<EOF;
<hr>
<form method="GET" action="$SCRIPT_NAME">
<p>正規表現:
<input type="text" name="search" value="$search">
<input type="hidden" name="sort" value="$sort">
<input type="submit" value="絞り込み検索">
</p>
</form>
EOF
    if (length($search)) {	# 検索
	@entries = grep(/$search/oi, @entries);
	print "<p>Perl で /$search/oi しています。grep -i とほぼ同じです。</p>";
 	print "<p><font color=\"red\">検索結果: ", $#entries + 1, "件</font></p>\n";
    }

    foreach my $cont (@entries) {
	my @tmp = ();
	$cont =~ s#<td>(.+?)</td>#push(@tmp,$1)#sgei;
	push(@problems, \@tmp) if @tmp > 0;
    }

    my $sortby = 0;
    $sortby = $1 if $sort =~ /(\d+)/;
    @problems = sort { fncmp($a->[$sortby], $b->[$sortby]) } @problems;
    @problems = reverse @problems if $sort =~ /r$/;

    print <<EOF;
<hr>
<table width="100%" border="1" bgcolor="$bgcolor">
<tr bgcolor="$bgcolor_head">
EOF
    for (my $i = 0; $i < @TABLE_LABEL; $i++) {
	print <<EOF;
<th>
<a href="$SCRIPT_NAME?sort=$i;search=$search">$TABLE_LABEL[$i]</a>
<a href="$SCRIPT_NAME?sort=${i}r;search=$search">(*)</a>
</th>
EOF
    }
    print "</tr>\n";

    for (my $i = $page * $MAX; $i < @problems && $i < ($page+1) * $MAX; $i++) {
	print "<tr valign=\"top\">\n";
	foreach my $cont (@{$problems[$i]}) {
	    $cont =~ s/^\s+//g;
	    $cont =~ s/\s+$//g;
	    ## とりあえず様子見。
	    # $cont =~ s#((https?|ftp)://[;\/?:@&=+\$,A-Za-z0-9\-_.!~*'()]+)#<a href="$1">$1</a>#gi;
	    print "<td>$cont</td>\n";
	}
	print "</tr>\n";
    }
    print "</table>\n";
    print_pages();
    print_html_foot();
}

# 数字を考慮したソート
sub fncmp() {
    my ($x, $y) = @_;
    $x =~ s/(\d+)/sprintf("%05d", $1)/ge;
    $y =~ s/(\d+)/sprintf("%05d", $1)/ge;
    return $x cmp $y;
}

sub print_pages() {
    my $base_url = "$SCRIPT_NAME?sort=$sort;search=$search";
    print "<p>ページ:\n";
    for (my $i = 0; $i*$MAX < @problems; $i++) {
	if ($i == $page) {
	    print "[", $i+1, "]\n";
	} else {
	    print "<a href=\"$base_url;page=$i\">[", $i+1, "]</a>\n";
	}
    }
    print "</p>\n";
}

sub print_html_head() {
    print <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja"><head><title>$TITLE</title></head><body>
<h1>$TITLE</h1>
<p>
本ページは<strong>個人的に</strong>作成しているものです。<br>
センターの<a href="$ORIG_URL">問題と対策のページ</a>の更新状況によっては、うまく表示されない場合があります。御了承ください。</p>
EOF
}

sub print_html_foot() {
    my $id = '$Id$';
    print <<EOF;
<hr><address>
<a href="http://nile.ulis.ac.jp/~masao/ulisonly/ipc-trouble.cgi">http://nile.ulis.ac.jp/~masao/ulisonly/ipc-trouble.cgi</a><br>
$id<br>
</address>
</body></html>
EOF
}

sub escape_html($) {
    my ($str) = @_;
    return undef if not defined $str;
    $str =~ s/&/&amp;/go;
    $str =~ s/</&lt;/go;
    $str =~ s/>/&gt;/go;
    $str =~ s/"/&quot;/go;
    return $str;
}

sub get_contents () {
    my @entries;
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new('GET', $ORIG_URL);
    my $res = $ua->request($req);
    if ($res->is_success) {
	my $tmp = $res->content;
	# $tmp =~ s/\s+/ /go;  # <pre>...</pre>対策でコメントアウト
	$tmp =~ s#<!--(.*?)-->##sgo;
	$tmp =~ s#<tr[^>]*>(.+?)</tr>#push(@entries,$1)#sgeio;
	# print "\@entries: $#entries\n";
    } else {
	print "<p><a href=\"$ORIG_URL\">問題と対策のページ</a>にアクセスできませんでした。</p>\n";
	print_html_foot();
	exit();
    }
    my $date = $res->headers->last_modified;
    # print "<p><a href=\"$ORIG_URL\">元のページ</a>";
    # print "（最終更新日: <strong>$date</strong>）" if defined $date;
    # print "</p>\n";
    return @entries;
}
