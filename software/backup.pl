#!/usr/bin/perl -w
# $Id$

use strict;

my $DIR = "/home/x/masao/Backup";
my $SSH_AGENT_ENV = "/tmp/.ssh-masao-agent.lnk";
my $RSYNC = "/usr/bin/rsync";
my @RSYNC_ARGS = ("-e", "/usr/bin/ssh", "-auqS", "--delete");

main();
sub main {
    my $from = $ARGV[0] || usage();

    my @path = split(/[:\/]/, $from);
    my $to = pop @path;

    unless (defined $to || -d "$DIR/$to") {
	mkdir("$DIR/$to", 0400) || die "mkdir error: $!";
    }

    unless (-x $RSYNC) {
	print "rsync command not executable: $RSYNC\n";
	exit;
    }

    load_sshenv();

    my @cmd = ($RSYNC, @RSYNC_ARGS, $from, "$DIR/$to");
    system(@cmd);
}

sub usage() {
    print "  USAGE:  $0 target\n";
    print "\tplease specify target host or directory\n";
    exit;
}

sub load_sshenv() {
    open(F, $SSH_AGENT_ENV) || die "open error: $SSH_AGENT_ENV: $!";
    while (my $line = <F>) {
	if ($line =~ /^setenv\s+(\S+)\s+(\S+);$/) {
	    $ENV{$1} = $2;
	}
    }
    close F;
}
