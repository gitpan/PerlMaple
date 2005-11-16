#: PerlMaple.pm
#: implementation for the PerlMaple class
#: v0.01
#: Copyright (c) 2005 Agent Zhang
#: 2005-11-14 2005-11-14

package PerlMaple;

use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('PerlMaple', $VERSION);

sub new {
    my $class = shift;
    if (maple_start()) {
        my $self = { _pack => __PACKAGE__ };
        return bless $self, $class;
    }
    return undef;
}

sub eval {
    my ($self, $exp) = @_;
    $exp =~ s/[\s\n\r]+$//s;
    if ($exp !~ /[;:]$/) {
        $exp .= ';';
    }
    #warn $exp;
    maple_eval($exp);
    if (maple_success()) {
        return maple_result();
    }
    return undef;
}

sub error {
    if (!maple_success()) {
        return maple_error();
    }
    return undef;
}

1;

__END__

=head1 NAME

PerlMaple - Perl binding for Waterloo's Maple software

=head1 SYNOPSIS

  use PerlMaple;

  my $maple = PerlMaple->new or
      die $maple->error;
  my $ans = $maple->eval('int(2*x^3,x);');
  defined $ans or die $maple->error;

=head1 DESCRIPTION

This is a very simple interface to Waterloo's Maple software via the OpenMaple
C interface.

=head1 INSTALLATION

Currently this software is only tested on Win32. To build this module
properly, you must first have Maple installed on your system and append
the paths of maplec.h and maplec.lib in your Maple installation to the
environments LIB and INC respectively. Because this module use Maple's
C interface via L<Inline::C>.

A typical path of maplec.h is "C:\Program Files\Maple 9\extern\include",
which should be appended to the INCLUDE environment. And a typical path
of maplec.lib is "C:\Program Files\Maple 9\bin.win", which should be
appended to the LIB environment. These paths may be different on your
machine but do depend on your Maple's version and location.

It may be similar on UNIX, but I haven't tried that.

=head2 EXPORT

None by default.

=head1 METHODS

=over

=item -E<gt>new()

Class constructor. It starts a Maple session if it does not exist. It should
be noting that although you're able to create more than one PerlMaple objects,
all these maple objects share the same Maple session. So the context of each
PerlMaple objects may be corrupted intentionally. If any error occurs, this
method will return undef value, and set the internal error buffer which you can
read by the -E<gt>error() method.

=item -E<gt>eval($command)

This method may be the most important one for this class. It evaluates the
command stored in the argument, and returns a string containing the result.
If an error occurs, it will return undef, and set the internal error buffer
which you can read by the -E<gt>error() method.

=item -E<gt>error()

It returns the error message issued by the Maple kernel.

=back

=head1 INTERNAL FUNCTIONS

=over

=item maple_error

=item maple_eval

=item maple_result

=item maple_start

=item maple_success

=back

=head1 SEE ALSO

L<http://www.maplesoft.com>

=head1 AUTHOR

Agent Zhang, E<lt>agent2002@126.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 Agent Zhang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
