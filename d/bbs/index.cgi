#!/usr/bin/env perl
# $Id$
use strict;

### �Խ����Ʋ�����
my $conf_file = "kuttukibbs.conf"; # �桼������ե�����ξ��

### �桼��������� (kuttukibbs.conf ������Ǥ��ޤ�)
my $log_dir = "kblog";		# �����ȥ����ե�������֤��ǥ��쥯�ȥ�
my $latest_comment_display_num = 20; # �ǿ����ɽ���ΤȤ��˰��٤�ɽ�������
my $kb_js_display_max = 5;	# ɽ�����륳���Ȥο� for js
my $kb_js_strlen_max = 40;	# 1 �����Ȥ�ɽ�������ʸ���� for js
my $admin_log_file = "kblog/log.txt"; # �������ѥ����ե�����
my $passwd = "";		# �������ѥѥ����
my $noname = "???";		# �ǥե���Ȥ���Ƽ�̾
my $page_template_default;
my $page_template_latest;
my $page_template_edit;
my $charset = "EUC-JP";		# ʸ��������

### �������Х��ѿ�
my $latest_id = -1;		# �ǿ��Υ����Ȥ� ID
my %com_hash;			# �����Ȥ��Ǽ����ϥå���
my $URLCHARS = "[-_.!~*'a-zA-Z0-9;/?:@&=+,%\#\$]";


# �桼������ե�������ɤ߹���
if (not -e $conf_file) {
    print "error: can't read $conf_file\n";
    exit;
}
open(CONF, "$conf_file") or die "can't open $conf_file : $!";
my $conf = join('', <CONF>);
eval $conf;

# ���߻���γ���
use POSIX qw(strftime);
my $what_time_is_it_now = strftime "%Y-%m-%d %H:%M:%S", localtime;

use CGI;
my $q = new CGI;
#print $q->Dump;

my $mode = $q->param('mode');

# �桼������
my $name = $q->param('name');
my $mail_or_url = $q->param('mail');
my $body = $q->param('body');

# header
if ($mode eq 'write') {
    escape_string(\$name);	
    escape_string(\$mail_or_url);	
    my $cookie = $q->cookie(-name=>'kuttukibbs', 
			    -value=>"$name\t$mail_or_url", 
			    -expires=>'+30d');
    print $q->header(-cookie=>$cookie, -charset=>$charset);
} else {
    print $q->header(-charset=>$charset);
    if (defined $q->cookie('kuttukibbs')) {
	($name, $mail_or_url) = split(/\t/, $q->cookie('kuttukibbs')); 
    }
    escape_string(\$name);	
    escape_string(\$mail_or_url);	
}

my $cgi_url = $q->url();

my $comments;
my $page_html;


if ($mode eq 'latest') {output_latest();}

# �������оݤξ���
my $logid = $q->param('id'); # �����Ȥ� ID�������ե�������������
$logid =~ s{[^a-zA-Z0-9\.\-\#_]}{_}g;
exit if ($logid =~ /^\s*$/);
my $target_url = id2url($logid); # �������оݤ� URL
$cgi_url .= "?id=$logid";
my $fn_pref = "$log_dir/$logid";

### �ɤ߹���
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
            write_to_jsfile($fn_pref.".js"); # JavaScript Feed �ե�����
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

### �񤭹���
if ($mode eq "write") {
    $name = $noname if ($name =~ /^\s*$/sm);
    
    if ($body !~ /\A\s*\Z/m) {
	escape_string(\$name);	
	escape_string(\$mail_or_url);	
	escape_string(\$body);

	$body =~ s/\r?\n/<br>/gsm;
	
	my $name_tmp = $name;
	if ($mail_or_url =~ /^http:\/\/$URLCHARS+$/) {
	    $name_tmp = qq(<a href="$mail_or_url">$name</a>);
	}
	
	$latest_id++;
	$com_hash{$latest_id}{n} = $name_tmp;
	$com_hash{$latest_id}{m} = $body;
	$com_hash{$latest_id}{d} = $what_time_is_it_now;
	
	write_to_logfile();	# �����ե�����ؤν񤭹���
	write_to_jsfile($fn_pref.".js"); # JavaScript Feed �ե�����ؤν񤭹���
	write_to_adminlogfile(); # �������ѥ����ե�����ؤν񤭹���
    }
}

### ɽ��
for (my $i = $latest_id; $i >= 0; $i--) {
    next unless defined $com_hash{$i};
    $comments .= make_comment_html($com_hash{$i}, $i + 1);
}

eval qq(\$page_html = << "FFF"\n$page_template_default\nFFF\n);
print $page_html;
exit;

#----------------------------------------------------------------------

###
sub escape_string {
    my ($sp) = @_;
    $$sp =~ s/</&lt;/g;
    $$sp =~ s/>/&gt;/g;
    $$sp =~ s/\"/&quot;/g;	# "
}


### �ե�������ɤ�
sub read_file {
    my ($fn, $strp) = @_;
#    if (-e $fn and -s $fn != 0) {
    if (-e $fn) {
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

### �����ȥ����ե��������Ϥ����ƥ����Ȥ��Ȥ� hash �˳�Ǽ���롣
sub set_comment_hash {
    my ($hashp, $allp) = @_;
    foreach (split(/\r?\n/, $$allp)) {
	if (/^([nmd])\[(\d+)\] = "(.*?)";$/) {
	    $hashp->{$2}{$1} = $3;
	    $latest_id = $2 if ($latest_id < $2);
	}
    }
}


### �����Ƚ����� HTML ���롣
sub make_comment_html {
    my ($commentp, $commentid) = @_;
    my $mes = $commentp->{'m'};
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


### �����ե�����ؤν񤭹���
sub write_to_logfile {
    my $fn = "$fn_pref.log";
    my $str;
    foreach (sort {$a <=> $b} keys %com_hash) {
	$str .= qq(n[$_] = "$com_hash{$_}{n}";\nm[$_] = "$com_hash{$_}{m}";
d[$_] = "$com_hash{$_}{d}";\n);
    }
    save_file($fn, \$str);
}


### JavaScript Feed �ե�����ؤν񤭹���
sub write_to_jsfile {
    my ($jsfn) = @_;
#    my $jsfn = "$fn_pref.js";
    my $str = "";
    my $cnt = $kb_js_display_max;
    for (my $i = $latest_id; $i >= 0; $i--) {
	next unless defined $com_hash{$i};

	my ($n,$m,$d)  = ($com_hash{$i}{n},$com_hash{$i}{m},$com_hash{$i}{d});
	$n =~ s/^(.{1000}).*$/$1/;
	$m =~ s/<br>//ig;	# ���ԥ����Ϻ��

	$n =~ s/\\/\\\\/g;
	$m =~ s/\\/\\\\/g;

	$n =~ s/\'/\\'/g;
	$m =~ s/\'/\\'/g;

	# ʸ��¿���Ȥ����������å� - charset�ˤ�����ꤢ�뤫��
	if ($m =~ s/^(([\x80-\xff].|[\x00-\x7f]){$kb_js_strlen_max}).*$/$1/) {
	    $m =~ s/((s?https?|ftp):\/\/$URLCHARS+)$/$2/;
	    $m .= "...";
	}
	# URL to anchor
	$m =~ s/((s?https?|ftp):\/\/$URLCHARS+)/<a href="$1">$1<\/a>/ig;

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


### �������ѥ����ե�����ؤν񤭹���
sub write_to_adminlogfile {
    my $str = "remote_host: ". $q->remote_host(). "\n";
    $str .= "id: $logid\n";
    $str .= "mail or url: $mail_or_url\n";
    $str .= << "ADD";		# �ɲ�����
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


### �Ƕ���Ƥ��줿�����Ȥ�ɽ��
sub output_latest {
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
			   n => $hash{$i}{'n'}, i => $id};
	}
	@lalist = (sort {$b->{d} cmp $a->{d}}
		   @lalist)[0..($latest_comment_display_num - 1)];
    }
    foreach my $i (@lalist) {
	last if $i eq "";
	$comments .= make_comment_html($i, 0);
    }

    $cgi_url .= "?mode=latest";

    eval qq(\$page_html = << "FFF"\n$page_template_latest\nFFF\n);
    print $page_html;
    exit;
}