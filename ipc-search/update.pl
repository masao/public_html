#!/usr/local/bin/perl -w
# $Id$

use strict;
$| = 1;

######グローバル変数 BEGIN
	#コマンド
my $Wget='/usr/local/bin/wget';
my $Mknmz='/usr/local/bin/mknmz';

	#ディレクトリ
my $BaseDir="/home/masao/Namazu/ipc-search";
my $HtmlDir="/home/masao/public_html/ipc-search";

######グローバル変数 END

if (-d $BaseDir) {
    chdir($BaseDir);
} else {
    die "ERROR: 作業ディレクトリ $BaseDir がありません。";
}

# 以前のファイル群は(一応)バックアップしておく。
if (-d "www.ulis.ac.jp") {
    print "古いファイルをバックアップします。... ";
    system "rm -rf www.ulis.ac.jp.old";
    system "mv -f www.ulis.ac.jp www.ulis.ac.jp.old";
    print "完了 - " . `date` ."\n";
}

# まず、ページを収集する。
print "文書群を収集します。... ";
system "$Wget --mirror --no-parent -l 0 -R .gif,.GIF,.jpg,.JPG,.jpeg,.avi,.mov,.mpg,.mpeg,.pic,.pict,.ppm,.tiff,.tiff,.vrml,.wrl,.xpm,.aif,.au,.cdr,.hcom,.mid,.pcm,.ra,.ram,.smp,.snd,.wav,.wave,.hqx,.lzh,.sit,.tar,.tgz,.zip,.exe,.class --proxy=off --output-file=wget.log -I ipc -I newsys http://www.ulis.ac.jp/" ;
print "完了 - " . `date` ."\n";

# 収集したページのうち、LastModifiedヘッダを返さないページの更新日付を
# 調整する。
print "ファイルの更新日付を調整します。... ";
system "$HtmlDir/settime.pl";
print "完了 - " . `date` ."\n";

# 次に、Indexingする。
print "Indexing を行います。\n";
if (-d "www.ulis.ac.jp") {
    $ENV{'LANG'} = "ja";
    system "$Mknmz --all --checkpoint --use-chasen --replace='s#${BaseDir}/#http://#;' ${BaseDir}/www.ulis.ac.jp/";
} else {
    die "収集した文書が $BaseDir/www.ulis.ac.jp にありません。";
}
print "完了 - " . `date` ."\n";

# 最後にトップページを自動的に更新させる。
print "トップページを更新します。... ";
if (-f "$BaseDir/NMZ.head.ja" &&
    -f "$HtmlDir/body.txt" &&
    -f "$BaseDir/NMZ.foot.ja") {
    system "cat $BaseDir/NMZ.head.ja $HtmlDir/body.txt $BaseDir/NMZ.foot.ja > $HtmlDir/index.html";
    print "完了 - " . `date` ."\n";
} else {
    warn "必要なファイルが見つかりません。";
}
