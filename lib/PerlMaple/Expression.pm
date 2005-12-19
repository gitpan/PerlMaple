#: PerlMaple/Expression.pm
#: Implementation for the PerlMaple::Expression class
#: v0.02
#: Copyright (c) 2005 Agent Zhang
#: 2005-12-19 2005-12-19

package PerlMaple::Expression;

use strict;
use warnings;
use PerlMaple;
#use Smart::Comments;

our $maple;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my $expr = shift;
    my $verified = shift;

    return undef if not defined $expr;

    $maple ||= PerlMaple->new;
    $expr = $maple->eval_cmd("$expr;") if not $verified;
    my $type = $maple->whattype($expr);
    ### Type: $type => $expr
    my @ops;
    my $self = bless {
        expr => $expr,
        type => $type,
        ops  => \@ops,
    }, $class;

    my $tmp_expr = ($type eq 'exprseq') ? "[$expr]" : $expr;
    my $nops = $maple->nops($tmp_expr);
    $self->{nops} = $nops;

    my $op = $maple->op(1, $tmp_expr);
    if ($nops == 1 and $op eq $expr) {
        push @ops, $op;
        return $self;
    }
    ### Got: $op => $expr
    push @ops, $class->new($op);

    for my $i (2..$nops) {
        my $op = $maple->op($i, $tmp_expr);
        push @ops, $class->new($op, 1);
    }
    return $self;
}

sub expr {
    return shift->{expr};
}

sub ops {
    my $self = shift;
    return wantarray ? @{$self->{ops}} : $self->{nops};
}

sub type {
    my $self = shift;
    my $type = shift;
    if (not $type) {
        return $self->{type};
    }
    if ($self->{type} eq 'exprseq') {
        return 1 if $type eq 'exprseq';
        return undef;
    }
    my $res = $maple->type($self->{expr}, $type);
    return ($res eq 'true') ? 1 : undef;
}

1;

__END__

=head1 NAME

PerlMaple::Expression - Perl AST for arbitrary Maple expressions

=head1 VERSION

This document describes PerlMaple::Expression 0.02 released on December 19, 2005.

=head1 SYNOPSIS

    use PerlMaple::Expression;

    $expr = PerlMaple::Expression->new('x^3+2*x-1');
    print $expr->expr;  # got: x^3+2*x-1
    print $expr->type;  # got: `+`

    @objs = $expr->ops;
    @exps = map { $_->expr } @objs;
    print "@exps";    # got: x^3 2*x -1

    # $objs[0] is another PerlMaple::Expression obj
    #    corresponding to 'x^3':
    print $objs[0]->type;  # got: `^`
    @exps = map { $_->expr } $objs[0]->ops;
    print "@exps";    # got: x 3

    # $objs[1] is yet another PerlMaple::Expression obj
    #    corresponding to '2*x':
    print $objs[1]->type;  # got: `*`
    @exps = map { $_->expr } $objs[1]->ops;
    print "@exps";    # got: 2 x

=head1 DESCRIPTION

This class represents an Abstract Syntactic Tree (AST) for any Maple expressions.
It provides several very useful methods and attributes to manipulate Maple
expressions effectively and cleanly.

Hey, there's no parser written in Perl! I used Maple's functions to import the ASTs.
For example, functions like C<whattype>, C<nops>, and C<op>. So, don't worry for
the sanity of this library.

=head1 METHODS

=over

=item -E<gt>new($expr, ?$verified)

This is the constructor of the PerlMaple::Expression class. The first argument
C<$expr> is any Maple expression (not Maple statements though) from which the
AST is constructed. The second argument C<$verified> is optional. When it's set true,
the expression will skip validity check in Maple's engine, otherwise the first
argument will be evaluated by Maple to verify its sanity. If the second argument
is absent, it is implied to be false. That's to say, verification will be
performed by default.

=item -E<gt>ops

In list context, the C<ops> method returns the list of operands of the current
Maple expression. Every element of the resulting list is still a PerlMaple::Expression
object.

Observe the following code:

    $ast = PerlMaple::Expression->new('[1,2,3]');
    @ops = $ast->ops;  # a list of PerlMaple::Expression instances
    @elems = map { $_->expr } @ops;  # we get a list of integers (1, 2, and 3)

We see, the array @ops will contain three PerlMaple::Expression objects corresponding
to Maple expressions '1', '2', and '3', respectively. Therefore, the following 
tests will pass:

    is $ops[0]->type, 'integer';
    is $ops[1]->type, 'integer';
    is $ops[2]->type, 'integer';

Internally, -E<gt>ops method calls Maple's C<op> function to get the operands.
For atomic expressions, such as integers and symbols, -E<gt>C<ops> will simply
return the expr itself.

When used in scalar context, this method will simply return the number of operands,
calculated by Maple's C<nops> function internally.

=item -E<gt>expr

Returns the expression corresponding to the current PerlMaple::Expression object.
Note that the string returned may be different from the one passed to the 
constructor. Because it will be evaluated in Maple to check the validity.
Hence, the following tests will pass:

    $ast = PerlMaple::Expression->new('2,        3,4');
    is $ast->expr, '2, 3, 4';

However, when you pass a true value as the second argument to the constructor,
the validity check will be skipped:

    $ast = PerlMaple::Expression->new('2,        3,4', 1);
    is $ast->expr, '2,        3,4';

=item -E<gt>type

Get the type of the current Maple expression via Maple's C<whattype> function.
It is worth mentioning that the type of the expression is evaluated when
the object is constructing, so there's no extra cost to invoke this method
repeatedly.

=item -E<gt>type($new_value)

Test whether the current Maple expression is of the specified type. Note
that this method calls Maple's C<type> function to test the type equality.
So the following tests will happily pass:

    $ast = PerlMaple::Expression->new('3.5');
    ok $ast->type($ast, 'numeric');
    ok $ast->type($ast, 'type');

When the expression is of type 'exprseq', this method won't use Maple's
C<type> function since it will croak on expression sequences. Instead,
the -E<gt>type method will return true if and only if the given type
is exactly the same as 'exprseq'.

=back

=head1 CODE COVERAGE

I use L<Devel::Cover> to test the code coverage of my tests, below is the 
L<Devel::Cover> report on this module's test suite (version 0.02):

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    blib/lib/PerlMaple.pm          94.8   86.4   66.7  100.0  100.0   98.1   93.2
    ...b/PerlMaple/Expression.pm  100.0   94.4   66.7  100.0  100.0    1.9   95.1
    Total                          97.1   90.0   66.7  100.0  100.0  100.0   94.1
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 AUTHOR

Agent Zhang, E<lt>agent2002@126.comE<gt>

=head1 SEE ALSO

L<PerlMaple>
