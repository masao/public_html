#!/usr/local/bin/perl -w
# $Id$

use strict;
$| = 1;

######グローバル変数 BEGIN
	#コマンド
my $Wget='/usr/local/bin/wget';
my $Mknmz='/usr/local/bin/mknmz';

my $WgetOpt = '--mirror -l 0 -R .gif,.GIF,.jpg,.JPG,.jpeg,.png,.PNG,.avi,.mov,.mpg,.mpeg,.pic,.pict,.ppm,.tiff,.tiff,.vrml,.wrl,.xpm,.aif,.au,.cdr,.hcom,.mid,.pcm,.ra,.ram,.smp,.snd,.wav,.wave,.hqx,.lzh,.sit,.tar,.tgz,.zip,.exe,.class --proxy=off';

	#ディレクトリ
my $BaseDir="/home/masao/Namazu/ipc-search";
my $HtmlDir="/home/masao/public_html/ipc-search";
######グローバル変数 END

main();
sub main {
    if (-d $BaseDir) {
	chdir($BaseDir);
    } else {
	die "ERROR: 作業ディレクトリ $BaseDir がありません。";
    }

    # 以前のファイル群は(一応)バックアップしておく。
    backup_dirs("www.ulis.ac.jp", "www.cc.tsukuba.ac.jp");

    # まず、ページを収集する。
    print "文書群を収集します。... ";
    system "$Wget $WgetOpt --output-file=wget.log -I ipc -I newsys http://www.ulis.ac.jp/ipc/" ;
    system "$Wget $WgetOpt --append-output=wget.log --no-parent http://www.cc.tsukuba.ac.jp/kasuga/";
    print "完了 - " . `date` ."\n";

    # 収集したページのうち、LastModifiedヘッダを返さないページの更新日付を
    # 調整する。
    print "ファイルの更新日付を調整します。... ";
    system "$HtmlDir/settime.pl";
    print "完了 - " . `date` ."\n";

    # 次に、Indexingする。
    print "Indexing を行います。\n";
    if (-d "www.ulis.ac.jp" &&
	-d "www.cc.tsukuba.ac.jp") {
	$ENV{'LANG'} = "ja";
	system "$Mknmz --all --checkpoint -f ${HtmlDir}/mknmzrc --replace='s#${BaseDir}/#http://#;' *.ac.jp";
    } else {
	die "収集した文書が $BaseDir/www.ulis.ac.jp にありません。";
    }
    print "完了 - " . `date` ."\n";

    print "お知らせを更新します。... ";
    my %loginfo = get_loginfo("$BaseDir/NMZ.log");
    update_news("$HtmlDir/body.txt", %loginfo);
    print "完了 - ". `date` ."\n";

    # 最後にトップページを自動的に更新させる。
    print "トップページを更新します。... ";
    if (-f "$BaseDir/NMZ.head.ja" &&
	-f "$HtmlDir/body.txt" &&
	-f "$BaseDir/NMZ.foot.ja") {
	system "cat $BaseDir/NMZ.head.ja $HtmlDir/body.txt $BaseDir/NMZ.foot.ja > $HtmlDir/index.html";
	chdir $HtmlDir;
	system "cvs commit -m 'regularly update.' body.txt index.html";
	print "完了 - " . `date` ."\n";
    } else {
	warn "必要なファイルが見つかりません。";
    }
}

sub get_loginfo($) {
    my ($file) = @_;
    my %info = ();
    open(LOG, $file) || die "can't open $file: $!";
    my @tmp = <LOG>;
    @tmp = reverse @tmp;
    for my $line (@tmp) {
	last if ($line =~ /^\[/);

	if ($line =~ /^(Added|Updated|Deleted|Total)\s+Documents:\s+([0-9,]+)/i) {
	    $info{lc($1)} = $2;
	}
    }
    return %info;
}

sub update_news($%) {
    my ($file, %info) = @_;
    my $flag = '<!-- What\'s New -->';	# 目印
    my $date = sprintf("%4d-%.2d-%.2d",
		       (localtime)[5]+1900,
		       (localtime)[4]+1,
		       (localtime)[3]);

    open(HTML, $file) || die "can't open $file: $!";
    my @tmp = <HTML>;
    close(HTML);

    open(HTML, ">$file") || die "can't open $file: $!";
    for my $line (@tmp) {
	if ($line =~ /$flag/i) {
	    print HTML "$flag\n";
	    print HTML "  <dt>$date\n";
	    print HTML "  <dd>". info2str(%info);
	} else {
	    print HTML $line;
	}
    }
    close(HTML);
}

sub info2str(%) {
    my (%info) = @_;
    my $retstr = "インデックスを更新。全 $info{'total'} URL。";
    my %infostr = ('added' => "追加",
		   'deleted' => "削除",
		   'updated' => "更新");
    my @tmp = ();
    foreach my $k (keys %infostr) {
	push @tmp, "$infostr{$k} $info{$k} 件" if defined $info{$k};
    }
    $retstr .= "（". join(@tmp, "、") ."）\n";
    return $retstr;
}

sub backup_dirs(@) {
    my (@dirs) = @_;
    foreach my $dir (@dirs) {
	if (-d $dir) {
	    print "$dir をバックアップします。... ";
	    system "rm -rf $dir.old";
	    system "mv -f $dir $dir.old";
	}
    }
    print "完了 - " . `date` ."\n";
}
