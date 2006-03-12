#!/usr/bin/perl -w
# $Id$

use strict;

my $SSH_AGENT_ENV = "/tmp/.ssh-masao-agent.lnk";
my $RSYNC = "/usr/bin/rsync";

sub load_sshenv() {
    open(F, $SSH_AGENT_ENV) || die "open error: $SSH_AGENT_ENV: $!";
    while (my $line = <F>) {
	if ($line =~ /^setenv\s+(\S+)\s+(\S+);$/) {
	    $ENV{$1} = $2;
	}
    }
    close(F);
}

load_sshenv();
system($RSYNC,
       "-arv","--exclude=test/","--exclude=private/","--delete-after",
       "./",
       "etk:www/masao/");
