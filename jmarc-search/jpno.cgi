#!/usr/local/bin/perl -w

use CGI qw(:all);
use FileHandle;
use NKF;
use strict;
$| = 1;

require 'jmarc.pl';

my $MARC_PREFIX = '/project/jmarc/Original';

my $q = CGI->new();
$q->autoEscape(undef);

main();
sub main {
    my $format = $q->param('format');
    my $jpno = $q->param('jpno');
    my $file = $q->param('file');
    my $display = $q->param('display'); # �ܺ��� (full, brief)

    if ($format eq "MARC") {
	print header(-type=>'text/plain', -charset=>'EUC-JP');
    } else {
	print header(-charset=>'EUC-JP');
	print html_head($jpno, $file);
    }
    if (defined $file) {
	my $fname = "$MARC_PREFIX/$file";
	if (! -f $fname || $file =~ /(\/|\.\.)/) {
	    print "Can't find file: ($file)\n";
	    exit 1;
	}
	my @records = jmarc::get_records(readfile($fname));
	foreach my $record (@records) {
	    my $jpno = jmarc::get_jpno($record);
	    if ($format eq 'MARC') {
		print nkf('-e', jmarc::as_text($record));
	    } elsif($format eq "HTML") {
		print jmarc::as_html($record, $display);
		display_navigation_bar($display, $jpno);
	    }
	}
    } else {
	my $jpno = $q->param('jpno');
	if (length($jpno) != 8) {
	    print "ERROR: JP�ֹ�� 8 ��ο�������ꤹ�٤��Ǥ���($jpno)\n";
	    exit 1;
	}
	my %filename; # �ե�����̾
	my %position; # �ե�������γ��ϰ���
	
	dbmopen(%filename, "jp-fname", 0444);
	dbmopen(%position, "jp-pos", 0444);
	
	if (defined $filename{$jpno}) {
	    my $fname = "$MARC_PREFIX/$filename{$jpno}";
	    if (! -f $fname) {
		print "Can't find file: ($fname)\n";
		exit 1;
	    }
	    my $record = jmarc::read_record($fname, $position{$jpno});
	    if ($format eq "MARC") {
		print nkf('-e', jmarc::as_text($record));
	    } elsif($format eq 'HTML') {
		print jmarc::as_html($record, $display);
		display_navigation_bar($display, $jpno);
	    }
	} else {
	    print "JP�ֹ� $jpno �ϸ��Ĥ���ޤ���Ǥ�����\n";
	}
    }
    print html_tail() if $format eq "HTML";
}

sub display_navigation_bar($$) {
    my ($display, $jpno) = @_;
    print "<div align=\"right\">\n";
    if (defined $display && $display eq "full") {
	print "<a href=\"$ENV{SCRIPT_NAME}?jpno=$jpno&format=HTML&display=brief\">[�ʰ�]</a>\n";
    } else {
	print "<a href=\"$ENV{SCRIPT_NAME}?jpno=$jpno&format=HTML&display=full\">[�ܺ�]</a>\n";
    }
    print "<a href=\"$ENV{SCRIPT_NAME}?jpno=$jpno&format=MARC\">[�����եƥ�����]</a></div>";
    print "<hr>\n";
}

sub html_head($$) {
    my ($jpno, $file) = @_;
    my $title = '';
    if (defined $jpno) {
	$title = "JP�ֹ�: $jpno";
    } else {
	$title = "�ե�����̾: $file";
    }
    my $html_head = <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
    "http://www.w3.org/TR/REC-html401/strict.dtd">
<html lang="ja">
<head>
<title>$title</title>
</head>
<body>
EOF

    return $html_head;
}

sub html_tail() {
    return "</body></html>\n";
}

sub readfile($) {
    my ($fname) = @_;

    my $fh = new FileHandle;
    $fh->open($fname) || die "$fname: $!";

    my $cont = '';
    my $size = -s $fh;
    read $fh, $cont, $size;

    $fh->close();
    return $cont;
}
