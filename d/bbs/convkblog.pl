#!/usr/bin/env perl
# $Id$
# v0.4 以前のログを新版用に変換するプログラム

### v0.4 以前のログ (kblog/ にある) を新版用に変換する手順
# % ls kblog
# 2001-05-25.html.js  2003-09-03.html.js  2003-11-03.html.js
# 2002-04-25.html.js  2003-09-04.html.js  2003-11-04.html.js
# ...
# % convkblog.pl kblog kblog-new
# COPY kblog-old/2001-05-25.html.js -> kblog-new/2001-05-25.log
# NEW kblog-new/2001-05-25.js
# COPY kblog-old/2002-04-25.html.js -> kblog-new/2002-04-25.log
# NEW kblog-new/2002-04-25.js
# COPY kblog-old/2003-06-26.html.js -> kblog-new/2003-06-26.log
# NEW kblog-new/2003-06-26.js
# ...
# % cp -ra kblog/log.txt kblog-new/
# % mv kblog kblog-old
# % mv kblog-new kblog


use strict;

my $kb_js_display_max = 5;	# 表示するコメントの数 for js
my $kb_js_strlen_max = 40;	# 1 コメントが表示される文字数 for js

### グローバル変数
my $latest_id = -1;		# 最新のコメントの ID
my %com_hash;			# コメントを格納するハッシュ

my ($olddir, $newdir) = @ARGV;
if ($olddir eq "" or $newdir eq "" or $olddir eq $newdir) {
    print "usage: prog olddir newdir\n";
    exit;
}

if (!-e $newdir) {
    mkdir $newdir, 0777;
}

foreach my $fn (<$olddir/*.js>) {
    my $all;
    read_file($fn, \$all);
    my $newjs = $fn;
    $newjs =~ s|^$olddir/|$newdir/|;

    $newjs =~ s/\.html//;	# カスタマイズ

    my $newlog = $newjs;
    $newlog =~ s/\.js$/.log/;

    save_file($newlog, \$all);
    chmod 0666, $newlog;
    print "COPY $fn -> $newlog\n";

    %com_hash = ();
    set_comment_hash(\%com_hash, \$all);

    write_to_jsfile($newjs);

    chmod 0666, $newjs;
    print "NEW $newjs\n";
}
exit;


### ファイルを読む
sub read_file {
    my ($fn, $strp) = @_;
    if (-e $fn and -s $fn != 0) {
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


### JavaScript ファイルへの書き込み
sub write_to_jsfile {
    my ($jsfn) = @_;
    my $str;
    my $cnt = $kb_js_display_max;
    for (my $i = $latest_id; $i >= 0; $i--) {
	next unless defined $com_hash{$i};

	my ($n,$m,$d)  = ($com_hash{$i}{n},$com_hash{$i}{m},$com_hash{$i}{d});
	$m =~ s/<br>//ig;	# 改行タグは削除

	$n =~ s/\\/\\\\/g;
	$m =~ s/\\/\\\\/g;

	$n =~ s/\'/\\'/g;
	$m =~ s/\'/\\'/g;

	# 文字多いときの末尾カット
	$m =~ s/^(([\x80-\xff]{2}|[\x00-\x7f]){$kb_js_strlen_max}).*$/$1/;

	$str .= << "JS";
document.writeln('<p><span class="canchor">_</span>');
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
