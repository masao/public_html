#!/usr/bin/perl -w
# $Id$

use strict;
use Proc::ProcessTable;

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
sub ssh_agent_starttime {
    my $t = new Proc::ProcessTable;
    foreach my $p ( @{$t->table} ) {
	return $p->start if $p->uid eq $< and $p->fname eq "ssh-agent";
    }
    warn "ssh-agent process not found.";
    return time;
}

if ( -r $SSH_AGENT_ENV and ssh_agent_starttime() <= (stat($SSH_AGENT_ENV))[9] ) {
    load_sshenv();
    system($RSYNC, "-ar", @ARGV);
} else {
    print "load_sshenv() failed.\n";
    print "Warn: ssh-agent start(". ssh_agent_starttime() .") > $SSH_AGENT_ENV mtime(". (stat($SSH_AGENT_ENV))[9] .")\n";
}
