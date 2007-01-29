#!/usr/bin/env perl
# $Id$
# v0.4 �����Υ������Ѥ��Ѵ�����ץ����

### v0.4 �����Υ� (kblog/ �ˤ���) �����Ѥ��Ѵ�������
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

my $kb_js_display_max = 5;	# ɽ�����륳���Ȥο� for js
my $kb_js_strlen_max = 40;	# 1 �����Ȥ�ɽ�������ʸ���� for js

### �����Х��ѿ�
my $latest_id = -1;		# �ǿ��Υ����Ȥ� ID
my %com_hash;			# �����Ȥ��Ǽ����ϥå���

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

    $newjs =~ s/\.html//;	# �������ޥ���

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


### �ե�������ɤ�
sub read_file {
    my ($fn, $strp) = @_;
    if (-e $fn and -s $fn != 0) {
	open(F, $fn) or die "can't open $fn : $!\n";
	$$strp = join('', <F>);
	close(F);
    }
}


### �ե�����򥻡���
sub save_file {
    my ($fn, $strp) = @_;
    open(F, "> $fn") or die "can't open $fn : $!\n";
    flock(F, 2);
    print F $$strp;
    close F;
}

### �����ȥ��ե��������Ϥ����ƥ����Ȥ��Ȥ� hash �˳�Ǽ���롣
sub set_comment_hash {
    my ($hashp, $allp) = @_;
    foreach (split(/\r?\n/, $$allp)) {
	if (/^([nmd])\[(\d+)\] = "(.*?)";$/) {
	    $hashp->{$2}{$1} = $3;
	    $latest_id = $2 if ($latest_id < $2);
	}
    }
}


### JavaScript �ե�����ؤν񤭹���
sub write_to_jsfile {
    my ($jsfn) = @_;
    my $str;
    my $cnt = $kb_js_display_max;
    for (my $i = $latest_id; $i >= 0; $i--) {
	next unless defined $com_hash{$i};

	my ($n,$m,$d)  = ($com_hash{$i}{n},$com_hash{$i}{m},$com_hash{$i}{d});
	$m =~ s/<br>//ig;	# ���ԥ����Ϻ��

	$n =~ s/\\/\\\\/g;
	$m =~ s/\\/\\\\/g;

	$n =~ s/\'/\\'/g;
	$m =~ s/\'/\\'/g;

	# ʸ��¿���Ȥ����������å�
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
