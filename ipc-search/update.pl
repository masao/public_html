#!/usr/local/bin/perl -w
# $Id$

use strict;
$| = 1;

######�����Х��ѿ� BEGIN
	#���ޥ��
my $Wget='/usr/local/bin/wget';
my $Mknmz='/usr/local/bin/mknmz';

	#�ǥ��쥯�ȥ�
my $BaseDir="/home/masao/Namazu/ipc-search";
my $HtmlDir="/home/masao/public_html/ipc-search";

######�����Х��ѿ� END

if (-d $BaseDir) {
    chdir($BaseDir);
} else {
    die "ERROR: ��ȥǥ��쥯�ȥ� $BaseDir ������ޤ���";
}

# �����Υե����뷲��(���)�Хå����åפ��Ƥ�����
if (-d "www.ulis.ac.jp") {
    print "�Ť��ե������Хå����åפ��ޤ���... ";
    system "rm -rf www.ulis.ac.jp.old";
    system "mv -f www.ulis.ac.jp www.ulis.ac.jp.old";
    print "��λ - " . `date` ."\n";
}

# �ޤ����ڡ�����������롣
print "ʸ�񷲤�������ޤ���... ";
system "$Wget --mirror --no-parent -l 0 -R .gif,.GIF,.jpg,.JPG,.jpeg,.avi,.mov,.mpg,.mpeg,.pic,.pict,.ppm,.tiff,.tiff,.vrml,.wrl,.xpm,.aif,.au,.cdr,.hcom,.mid,.pcm,.ra,.ram,.smp,.snd,.wav,.wave,.hqx,.lzh,.sit,.tar,.tgz,.zip,.exe,.class --proxy=off --output-file=wget.log -I ipc -I newsys http://www.ulis.ac.jp/" ;
print "��λ - " . `date` ."\n";

# ���������ڡ����Τ�����LastModified�إå����֤��ʤ��ڡ����ι������դ�
# Ĵ�����롣
print "�ե�����ι������դ�Ĵ�����ޤ���... ";
system "$HtmlDir/settime.pl";
print "��λ - " . `date` ."\n";

# ���ˡ�Indexing���롣
print "Indexing ��Ԥ��ޤ���\n";
if (-d "www.ulis.ac.jp") {
    $ENV{'LANG'} = "ja";
    system "$Mknmz --all --checkpoint --use-chasen --replace='s#${BaseDir}/#http://#;' ${BaseDir}/www.ulis.ac.jp/";
} else {
    die "��������ʸ�� $BaseDir/www.ulis.ac.jp �ˤ���ޤ���";
}
print "��λ - " . `date` ."\n";

# �Ǹ�˥ȥåץڡ�����ưŪ�˹��������롣
print "�ȥåץڡ����򹹿����ޤ���... ";
if (-f "$BaseDir/NMZ.head.ja" &&
    -f "$HtmlDir/body.txt" &&
    -f "$BaseDir/NMZ.foot.ja") {
    system "cat $BaseDir/NMZ.head.ja $HtmlDir/body.txt $BaseDir/NMZ.foot.ja > $HtmlDir/index.html";
    print "��λ - " . `date` ."\n";
} else {
    warn "ɬ�פʥե����뤬���Ĥ���ޤ���";
}
