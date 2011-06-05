#!perl
use strict;
use warnings FATAL => 'all';
use Test::More;

use POSIX::pselect;


is scalar pselect(undef, undef, undef, 0, undef), 0;

my(undef, $slept) = pselect(undef, undef, undef, 0.1, undef);
cmp_ok $slept, '>=', 0.1, 'pselect() as sleep()';

open my $fh, '+<', 'README' or die $!;

my $rfdset = '';
my $wfdset = '';

vec($rfdset, fileno($fh), 1) = 1;
vec($wfdset, fileno($fh), 1) = 1;

is scalar( pselect($rfdset, $rfdset, undef, 0, [qw(INT)]) ), 2;

eval {
    pselect(undef, undef, undef, 0, [qw(hogehoge)]);
};
like $@, qr/unrecognized signal name "hogehoge"/;

done_testing;
