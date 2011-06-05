package POSIX::pselect;
use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.01';

use Exporter ();
our @ISA    = qw(Exporter);
our @EXPORT = qw(pselect);

use XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;
__END__

=head1 NAME

POSIX::pselect - Perl extention to do something

=head1 VERSION

This document describes POSIX::pselect version 0.01.

=for test_synopsis my($rfdset, $wfdset, $efdset, $timeout, $sigset);

=head1 SYNOPSIS

    use POSIX::pselect;

    pselect($rfdset, $wfdset, $efdset, $timeout, $sigset);

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Fuji, Goro (gfx) E<lt>gfuji@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, Fuji, Goro (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
