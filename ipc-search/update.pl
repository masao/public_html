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

print "���Τ餻�򹹿����ޤ���... ";
my %loginfo = get_loginfo("$BaseDir/NMZ.log");
update_news("$HtmlDir/body.txt", %loginfo);
print "��λ - ". `date` ."\n";

# �Ǹ�˥ȥåץڡ�����ưŪ�˹��������롣
print "�ȥåץڡ����򹹿����ޤ���... ";
if (-f "$BaseDir/NMZ.head.ja" &&
    -f "$HtmlDir/body.txt" &&
    -f "$BaseDir/NMZ.foot.ja") {
    system "cat $BaseDir/NMZ.head.ja $HtmlDir/body.txt $BaseDir/NMZ.foot.ja > $HtmlDir/index.html";
    chdir $HtmlDir;
    system "cvs commit -m 'regularly update.' body.txt index.html";
    print "��λ - " . `date` ."\n";
} else {
    warn "ɬ�פʥե����뤬���Ĥ���ޤ���";
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
    my $flag = '<!-- What\'s New -->';	# �ܰ�
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
	    print HTML "  <dd>����ǥå����򹹿����� $info{'total'} URL����";
	    print HTML "�ɲ� $info{'added'}" if (defined($info{'added'}));
	    print HTML "����� $info{'deleted'}" if (defined($info{'deleted'}));
	    print HTML "������ $info{'updated'}" if (defined($info{'updated'}));
	    print HTML "��\n";
	} else {
	    print HTML $line;
	}
    }
    close(HTML);
}
