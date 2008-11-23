#!/usr/bin/env perl
# -*-CPerl-*-
# $Id$
use strict;
use POSIX qw(strftime);
use CGI;
use CGI::Carp;

### 編集して下さい
my $conf_file = "kuttukibbs.conf"; # ユーザ設定ファイルの場所

### ユーザ設定項目 (kuttukibbs.conf で設定できます)
my $log_dir = "kblog";		# コメントログファイルを置くディレクトリ
my $latest_comment_display_num = 20; # 最新投稿表示のときに一度に表示する数
my $kb_js_display_max = 5;	# 表示するコメントの数 for js
my $kb_js_strlen_max = 40;	# 1 コメントが表示される文字数 for js
my $admin_log_file = "kblog/log.txt"; # 管理者用ログファイル
my $passwd = "";		# 管理者用パスワード
my $noname = "???";		# デフォルトの投稿者名
my $page_template_default;
my $page_template_latest;
my $page_template_edit;
my $charset = "EUC-JP";		# 文字コード
my $css = "diary.css";
my $header = "";
my $footer = "";

### グローバル変数
my $latest_id = -1;		# 最新のコメントの ID
my %com_hash;			# コメントを格納するハッシュ
my $URLCHARS = "[-_.!~*'a-zA-Z0-9;/?:@&=+,%\#\$]";


# ユーザ設定ファイルの読み込み
if (not -e $conf_file) {
    die "error: can't read $conf_file\n";
}
open(CONF, "$conf_file") or die "can't open $conf_file : $!";
my $conf = join('', <CONF>);
eval $conf;

# 現在時刻の獲得
my $what_time_is_it_now = strftime "%Y-%m-%d %H:%M:%S", localtime;

my $q = new CGI;
#print $q->Dump;

my $mode = $q->param('mode');
my $logid = $q->param('id'); # コメントの ID。ログファイル指定に利用
$mode = "latest" if not defined $mode and not defined $logid;

# ユーザ情報
my $name = $q->param('name');
my $mail_or_url = $q->param('mail');
my $body = $q->param('body');

my $content_type = 'text/html';
$content_type = 'text/xml' if $mode eq 'rss';

# header
if ($mode eq 'write') {
    my $cookie = $q->cookie(-name=>'kuttukibbs',
			    -value=>"$name\t$mail_or_url",
			    -expires=>'+30d');
    print $q->header(-cookie=>$cookie, -charset=>$charset);
} else {
    print $q->header(-type=>$content_type, -charset=>$charset);
    if (defined $q->cookie('kuttukibbs')) {
	($name, $mail_or_url) = split(/\t/, $q->cookie('kuttukibbs')); 
    }
}

my $cgi_url = $q->url();

my $comments;
my $page_html;


if ($mode eq 'latest') {
    output_latest();
} elsif ($mode eq 'rss') {
    output_latest_rss();
}

# コメント対象の情報
$logid =~ s{[^a-zA-Z0-9\.\-\#_]}{_}g;
die( 'invalid id' ) if ($logid =~ /^\s*$/);
my $target_url = id2url($logid); # コメント対象の URL
$cgi_url .= "?id=$logid";
my $fn_pref = "$log_dir/$logid";

### 読み込み
my $fn = "$fn_pref.log";
my $all;
read_file($fn, \$all);

if ($mode eq "edit") {
    my $co = $q->param('content');
    if (defined $co) {
	my $pw = $q->param('passwd');
	if (defined $pw and $pw ne "" and $pw eq $passwd) { 
	    rename $fn, $fn."~";
	    save_file($fn, \$co);
	    read_file($fn, \$all);
	    set_comment_hash(\%com_hash, \$all);
            write_to_jsfile($fn_pref.".js"); # JavaScript Feed ファイル
            %com_hash = ();
	} else {
	    print "wrong password!\n";
	}
    } else {
	my $content = $all;
	$content =~ s/&/&amp;/g;
	eval qq(\$page_html = << "FFF"\n$page_template_edit\nFFF\n);
	print $page_html;
	exit;
    }
}

set_comment_hash(\%com_hash, \$all);

### 書き込み
if ($mode eq "write") {
    $name = $noname if ($name =~ /^\s*$/sm);
    
    if ($body !~ /\A\s*\Z/m) {
	# Spam対策;
	my @spam;

	# 特定のURLリンク記法やHTMLリンク記法は禁止
	@spam = ($body =~ /(\[url=https?:\/\/|<a\s+href\s*=\s*["']?\s*https?:\/\/)/gmoi);
	error("リンク記法が含まれています。\nYour comment contains a inappropriate hyperlink format.") if scalar(@spam) > 0;

	# URLを3つ以上書くのは禁止
	@spam = ($body =~ /https?:\/\//gmo);
	error("複数のURLが書かれています。\nYour comment contains too many URLs.") if scalar(@spam) > 2;

	# 特定の文字列を禁止
	@spam = ($body =~ /\b(good|nice|cool|funny|best|great) site/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;

	# 特定のURLを禁止
	@spam = ($body =~ /\bhttps?:\/\/(\w+\.)?google\.(com|us|jp)\/group\/\w?\w?(ticket|teens)/gmoi);
	error("禁止されたURLが含まれています。\nYour comment contains a spamming URL.") if scalar(@spam) > 0;

	$name = CGI::escapeHTML( $name );
	$mail_or_url = CGI::escapeHTML( $mail_or_url );
	$body = CGI::escapeHTML( $body );

	$body =~ s/\r?\n/<br>/gsm;

	my $name_tmp = $name;
	if ($mail_or_url =~ /^http:\/\/$URLCHARS+$/) {
	    $name_tmp = qq(<a href="$mail_or_url">$name</a>);
	}

	$latest_id++;
	$com_hash{$latest_id}{n} = $name_tmp;
	$com_hash{$latest_id}{m} = $body;
	$com_hash{$latest_id}{d} = $what_time_is_it_now;

	write_to_logfile();	# ログファイルへの書き込み
	write_to_jsfile($fn_pref.".js"); # JavaScript Feed ファイルへの書き込み
	write_to_adminlogfile(); # 管理者用ログファイルへの書き込み
    }
}

### 表示
for (my $i = $latest_id; $i >= 0; $i--) {
    next unless defined $com_hash{$i};
    $comments .= make_comment_html($com_hash{$i}, $i + 1);
}

eval qq(\$page_html = << "FFF"\n$page_template_default\nFFF\n);
print $page_html;
exit;

#----------------------------------------------------------------------

sub error {
    my ($str) = @_;
    print <<EOF;
<html><head><title>Internal Server Error</title></head>
<body>
<h1>Internal Server Error</h1>
<pre>
$str
</pre>
<p><a href="javascript:history.back()">[Back]</a></p>
</body>
</html>
EOF
    exit;
}

### ファイルを読む
sub read_file {
    my ($fn, $strp) = @_;
#    if (-e $fn and -s $fn != 0) {
    if (-e $fn) {
	open(F, $fn) or die "can't open $fn : $!\n";
	$$strp = join('', <F>);
	close(F);
    }
}

### ファイルをセーブ
sub save_file {
    my ($fn, $strp) = @_;
    open(F, "> $fn") or die "can't open $fn : $!\n";
    flock(F, 2);
    print F $$strp;
    close F;
}

### コメントログファイルを解析し、各コメントごとに hash に格納する。
sub set_comment_hash {
    my ($hashp, $allp) = @_;
    foreach (split(/\r?\n/, $$allp)) {
	if (/^([nmd])\[(\d+)\] = "(.*?)";$/) {
	    $hashp->{$2}{$1} = $3;
	    $latest_id = $2 if ($latest_id < $2);
	}
    }
}


### コメント出力用 HTML を作る。
sub make_comment_html {
    my ($commentp, $commentid) = @_;
    my $mes = $commentp->{'m'};
    #$mes = CGI::escapeHTML( $mes );
    $mes =~ s{((s?https?|ftp)://($URLCHARS+))}{<a href="$1">$1</a>}g;

    my $anchor = qq(<span class="canchor">*</span>);
    my $page_info = "";
    if (defined $commentp->{i}) {
	my $id = $commentp->{i};
	my $url = id2url($id);
	my $bbs_url = "$cgi_url?id=$id";
	$page_info = qq(<span class="page">[<a href="$url">$url</a>, 
			<a href="$bbs_url">BBS</a>]</span>);
    } else {
	$anchor = qq(<a name="$commentid" href="$cgi_url\#$commentid">
		     <span class="canchor">*</span></a>);
    }
    my $rv .= << "DAY"
<div class="acomment">
<div class="commentator">
$anchor
<span class="commentator">$$commentp{'n'}</span>
<span class="commenttime">$$commentp{'d'}</span>
$page_info
</div>
<p>$mes</p>
</div>
DAY
    ;
    return $rv;
}

### ログファイルへの書き込み
sub write_to_logfile {
    my $fn = "$fn_pref.log";
    my $str;
    foreach (sort {$a <=> $b} keys %com_hash) {
	$str .= qq(n[$_] = "$com_hash{$_}{n}";\nm[$_] = "$com_hash{$_}{m}";
d[$_] = "$com_hash{$_}{d}";\n);
    }
    save_file($fn, \$str);
}


### JavaScript Feed ファイルへの書き込み
sub write_to_jsfile {
    my ($jsfn) = @_;
#    my $jsfn = "$fn_pref.js";
    my $str = "";
    my $cnt = $kb_js_display_max;
    for (my $i = $latest_id; $i >= 0; $i--) {
	next unless defined $com_hash{$i};

	my ($n,$m,$d)  = ($com_hash{$i}{n},$com_hash{$i}{m},$com_hash{$i}{d});
	$n =~ s/^(.{1000}).*$/$1/;
	$m =~ s/<br>//ig;	# 改行タグは削除

	$n =~ s/\\/\\\\/g;
	$m =~ s/\\/\\\\/g;

	$n =~ s/\'/\\'/g;
	$m =~ s/\'/\\'/g;

	# 文字多いときの末尾カット - charsetにより問題あるかも
	if ($m =~ s/^(([\x80-\xff].|[\x00-\x7f]){$kb_js_strlen_max}).*$/$1/) {
	    $m =~ s/((s?https?|ftp):\/\/$URLCHARS+)$/$2/;
	    $m .= "...";
	}
	# URL to anchor
	$m =~ s/((s?https?|ftp):\/\/$URLCHARS+)/<a href="$1">$1<\/a>/ig;

	my $commentid = $i + 1;

	$str .= << "JS";
document.writeln('<p><span class="canchor"><a href="$cgi_url#$commentid">_</a></span>');
document.writeln('<span class="commentator">$n</span>');
document.writeln(' [$m]</p>');
JS
    ;

	$cnt--;
	last if ($cnt <= 0);
    }
    if ((keys %com_hash) > $kb_js_display_max) {
	$str .= << "JS";
document.writeln('<p><span class="canchor">_</span>');
document.writeln('<span class="commentator">...</span></p>');
JS
    ;
    }

    save_file($jsfn, \$str);
}


### 管理者用ログファイルへの書き込み
sub write_to_adminlogfile {
    my $str = "remote_host: ". $q->remote_host(). "\n";
    $str .= "id: $logid\n";
    $str .= "mail or url: $mail_or_url\n";
    $str .= << "ADD";		# 追加内容
n[$latest_id] = "$name";
m[$latest_id] = "$body";
d[$latest_id] = "$what_time_is_it_now";

ADD
    ;
    open(F, ">> $admin_log_file") or die "can't open $admin_log_file : $!\n";
    flock(F, 2);
    print F $str;
    close(F);
}


sub get_latest_list {
    my @fl = <$log_dir/*.log>;
    my @lalist;
    foreach my $f (@fl) {
	open(F, $f) or die "$! $f";
	next if (-s $f == 0);
	my $all = join('', <F>);
	my %hash;

	my ($id) = ($f =~ /([^\/]+)\.log$/);
	set_comment_hash(\%hash, \$all);
	foreach my $i (keys %hash) {
	    push @lalist, {d => $hash{$i}{'d'}, m => $hash{$i}{'m'},
			   n => $hash{$i}{'n'}, i => $id,
			   ii => $i,
			  };
	}
	my $last = $latest_comment_display_num - 1;
	$last = $#lalist if $last > $#lalist;
	@lalist = (sort {$b->{d} cmp $a->{d}}
		   @lalist)[0..$last];
    }
    return @lalist;
}

### 最近投稿されたコメントを表示
sub output_latest {
    my @lalist = get_latest_list();
    foreach my $i (@lalist) {
	last if $i eq "";
	$comments .= make_comment_html($i, 0);
    }

    $cgi_url .= "?mode=latest";

    eval qq(\$page_html = << "FFF"\n$page_template_latest\nFFF\n);
    print $page_html;
    exit;
}
sub output_latest_rss {
    my @lalist = get_latest_list();
    $cgi_url .= "?mode=latest";

    my $mtime = (stat($admin_log_file))[9];
    my $date = strftime("%y-%m-%dT%h:%M:%sZ", gmtime($mtime));
    print <<RSS;
<?xml version="1.0" encoding="$charset"?>
<rdf:RDF
 xmlns="http://purl.org/rss/1.0/"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:content="http://purl.org/rss/1.0/modules/content/"
 xmlns:admin="http://webns.net/mvcb/"
 xml:lang="ja">
<channel rdf:about="$cgi_url">
 <title>Kuttuki BBS</title>
 <link>$cgi_url</link>
 <description>Kuttuki BBS</description>
 <dc:language>ja</dc:language>
 <dc:date>$date</dc:date>
 <admin:generatorAgent rdf:resource="kuttukibbs"/>
 <items>
 <rdf:Seq>
RSS
    foreach my $item (@lalist) {
	my $commentid = $item->{ii};
	my $url = $q->url() ."?id=". $item->{i} ."#". $commentid;
	print qq{  <rdf:li rdf:resource="$url"/>\n};
    }
    print <<RSS;
 </rdf:Seq>
 </items>
</channel>
RSS
    foreach my $item (@lalist) {
	my $commentid = $item->{ii};
	my $url = $q->url() ."?id=". $item->{i} ."#". $commentid;
	my $cont = $item->{m};
	$cont =~ s/<br>/\n/g;
	my $name = $item->{n};
	my $time = $item->{d};
	print <<RSS;
<item rdf:about="$url">
 <link>$url</link>
 <description>$cont</description>
 <dc:creator>$name</dc:creator>
 <dc:date>$time</dc:date>
</item>
RSS
    }
    print <<RSS;
</rdf:RDF>
RSS
    exit;
}
