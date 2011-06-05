#!perl -w
use strict;
use Test::More;

use POSIX::pselect;

# test POSIX::pselect here
is POSIX::pselect::hello(), 'Hello, world!';

done_testing;
