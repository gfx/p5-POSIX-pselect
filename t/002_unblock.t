#!perl
use strict;
use warnings FATAL => 'all';
use Errno ();
use POSIX ();
use POSIX::pselect;
use Time::HiRes ();

use Test::More tests => 5;

sub doit {
    my $got_usr1 = 0;
    # setup sighandler and block SIGUSR1
    local $SIG{USR1} = sub { $got_usr1 = 1 };
    POSIX::sigprocmask(POSIX::SIG_BLOCK(),
        POSIX::SigSet->new(POSIX::SIGUSR1()));
    # send SIGUSR1 to myself
    my $pid = fork || do {
        kill POSIX::SIGUSR1(), getppid;
        exit(0);
    };
    while (wait() != $pid) {}
    ok ! $got_usr1;
    # perform a pselect
    my $now = Time::HiRes::time;
    my $ret = POSIX::pselect::pselect(undef, undef, undef, 1, do {
        my $ss = POSIX::SigSet->new;
        $ss->fillset;
        $ss->delset(POSIX::SIGUSR1());
        $ss;
    });
    ok $ret <= 0;
    is $! + 0, Errno::EINTR();
    ok $got_usr1;
    my $elapsed = Time::HiRes::time - $now;
    ok $elapsed < 0.5;
}

doit();

done_testing;
