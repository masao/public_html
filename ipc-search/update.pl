#!/usr/local/bin/perl -w
# $Id$

use strict;
use IO::File;
use File::Find;
use Digest::MD5;

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
    backup_dirs("www.slis.tsukuba.ac.jp", "www.cc.tsukuba.ac.jp");

    # まず、ページを収集する。
    print "文書群を収集します。... ";
    system "$Wget $WgetOpt --output-file=wget.log -I ipc -I newsys -I subnet http://www.slis.tsukuba.ac.jp/ipc/" ;
    system "$Wget $WgetOpt --append-output=wget.log --no-parent http://www.cc.tsukuba.ac.jp/kasuga/";
    print "完了 - " . `date` ."\n";

    if (-d "www.slis.tsukuba.ac.jp" &&
	-d "www.cc.tsukuba.ac.jp") {
	# 収集したページのうち、LastModifiedヘッダを返さないページの更新日付を
	# 調整する。
	print "ファイルの更新日付を調整します。... ";
	settime("www.slis.tsukuba.ac.jp", "www.cc.tsukuba.ac.jp");
	print "完了 - " . `date` ."\n";

	# 次に、Indexingする。
	print "Indexing を行います。\n";
	$ENV{'LANG'} = "ja";
	system "$Mknmz --all --checkpoint -f ${HtmlDir}/mknmzrc --replace='s#${BaseDir}/#http://#; s#/index.html$#/#;' *.ac.jp";
    } else {
	die "収集した文書が $BaseDir/www.slis.tsukuba.ac.jp にありません。";
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
    my $fh = fopen($file);
    my @tmp = <$fh>;
    @tmp = reverse @tmp;
    for my $line (@tmp) {
	last if ($line =~ /^\[/);

	if ($line =~ /^(Added|Updated|Deleted|Total)\s+Documents:\s+([0-9,]+)$/i) {
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

    my $fh = fopen($file);
    my @tmp = <$fh>;
    undef $fh;

    $fh = fopen(">$file");
    for my $line (@tmp) {
	if ($line =~ /$flag/i) {
	    print $fh "$flag\n";
	    print $fh "  <dt>$date\n";
	    print $fh "  <dd>". info2str(%info);
	} else {
	    print $fh $line;
	}
    }
    undef $fh;
}

sub info2str(%) {
    my (%info) = @_;
    my $retstr = "インデックスを更新。全 $info{'total'} URL。";
    my %infostr = ('added' => "追加",
		   'deleted' => "削除",
		   'updated' => "更新");
    my @tmp = ();
    foreach my $k (keys %infostr) {
	push(@tmp, "$infostr{$k} $info{$k}") if defined $info{$k};
    }
    $retstr .= "（". join("、", @tmp) ."）\n";
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

sub settime(@) {
    my (@dirs) = @_;
    my %files = ();

    my $file = "$HtmlDir/digest";
    if (my $fh = fopen($file)) {
	while (<$fh>) {
	    chomp;
	    my ($path, $info) = split(/\t/, $_, 2);
	    $files{$path} = $info;
	}
    }

    my $wanted = sub {
	my $f = $_;
	return unless -f $f;
	my $name = $File::Find::name;
	my @stat = stat($f);
	my $mtime = $stat[9];
	my $size = $stat[7];
	my $digest = md5_file($f);
	if (defined($files{$name})) {
	    my ($mtime_old, $size_old, $digest_old) = split(/\t/, $files{$name});
	    if ($size == $size_old && $digest eq $digest_old) {
		$mtime = $mtime_old;
		utime(time, $mtime, $f);
	    }
	}
	$files{$name} = join("\t", $mtime, $size, $digest);
    };
    find($wanted, @dirs);

    my $fh = fopen(">$file.new");
    foreach my $f (sort keys %files) {
	print $fh "$f\t$files{$f}\n";
    }
    undef $fh;

    if (-e $file) {
	rename($file, "$file.old") || die "Can't rename $file";
    }
    rename("$file.new", $file) || die "Can't rename $file.new";
}

sub md5_file($) {
    my ($file) = @_;
    my $md5 = Digest::MD5->new;
    my $fh = fopen($file);
    return $md5->addfile($fh)->hexdigest;
}

sub fopen($) {
    my ($file) = @_;
    my $fh = new IO::File;
    $fh->open($file) || die "$file: $!";
    $fh->autoflush(1);
    return $fh;
}
