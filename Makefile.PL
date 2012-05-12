use strict;
use warnings;

use inc::Module::Install;

all_from 'lib/POSIX/pselect.pm';

use_xshelper;
cc_warnings;
cc_src_paths 'src';

test_requires 'Test::More'     => '0.88';
test_requires 'Test::Requires' => '0.06';

auto_set_repository;

tests_recursive;
author_tests 'xt';


clean_files qw(
    POSIX-pselect-*
    *.stackdump
    cover_db *.gcov *.gcda *.gcno
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
