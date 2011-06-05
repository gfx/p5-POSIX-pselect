#!perl -w
use strict;
use Test::Requires { 'Test::LeakTrace' => 0.13 };
use Test::More;

use POSIX::pselect;

no_leaks_ok {
    # use POSIX::pselect here
};

done_testing;
