use strict;
use warnings;

use Test::More tests => 56;
use Test::Deep;

my $pack;
BEGIN {
    $pack = 'PerlMaple::Expression'; 
    use_ok($pack);
}

my $ast = $pack->new;
ok !defined $ast, 'empty expr results in undef obj';

$ast = $pack->new('3');
ok $ast, 'obj ok';
isa_ok $ast, $pack;
is $ast->expr, '3', 'method expr';

cmp_deeply(
    $ast,
    bless({
        nops => 1,
        type => 'integer',
        expr => '3',
        ops => ['3'],
    }, $pack),
    'check the obj internals'
);
is $ast->type, 'integer', 'method type';
ok $ast->type('integer'), 'method type';
ok $ast->type('type'), 'method type';
ok $ast->type('nonnegative'), 'method type';
ok not $ast->type('float');
ok not $ast->type('list');

$ast = $ast->new('3.5');
ok $ast, 'obj ok';
isa_ok $ast, $pack;
is $ast->expr, '3.5';

my @ops = (
    bless({
        nops => 1,
        type => 'integer',
        expr => '35',
        ops => ['35'],
    }, $pack),
    bless({
        nops => 1,
        type => 'integer',
        expr => '-1',
        ops => ['-1'],
    }, $pack),
);

cmp_deeply(
    $ast,
    bless({
        nops => 2,
        type => 'float',
        expr => '3.5',
        ops => \@ops,
    }, $pack),
    'check the obj internals'
);
is $ast->type, 'float';
ok $ast->type('float');
ok $ast->type('type');
ok $ast->type('numeric');
ok not $ast->type('integer');
ok not $ast->type('list');

cmp_deeply([$ast->ops], \@ops);

$ast = $ast->new("[3,42,'a']");
ok $ast, 'obj ok';
isa_ok $ast, $pack;
is $ast->expr, "[3, 42, a]", 'method expr';

@ops = (
    bless({
        nops => 1,
        type => 'integer',
        expr => '3',
        ops => ['3'],
    }, $pack),
    bless({
        nops => 1,
        type => 'integer',
        expr => '42',
        ops => ['42'],
    }, $pack),
    bless({
        nops => 1,
        type => 'symbol',
        expr => 'a',
        ops => ['a'],
    }, $pack),
);

cmp_deeply(
    $ast,
    bless({
        nops => 3,
        type => 'list',
        expr => "[3, 42, a]",
        ops => \@ops,
    }, $pack),
    'check the obj internals'
);
is $ast->type, 'list';
ok not $ast->type('float');
ok not $ast->type('numeric');
ok not $ast->type('integer');
ok $ast->type('list');
ok not $ast->type('type');

cmp_deeply [$ast->ops], \@ops;

my @elems;
foreach my $elem ($ast->ops) {
    push @elems, $elem->expr;
}
cmp_deeply \@elems, [qw(3 42 a)];

$ast = $pack->new('2,      3');
ok $ast;
isa_ok $ast, $pack;
is $ast->expr, '2, 3';
cmp_deeply(
    $ast,
    bless({
        nops => 2,
        type => 'exprseq',
        expr => '2, 3',
        ops => [
            bless({
                nops => 1,
                type => 'integer',
                expr => '2',
                ops => ['2'],
            }, $pack),
            bless({
                nops => 1,
                type => 'integer',
                expr => '3',
                ops => ['3'],
            }, $pack),
        ],
    }, $pack),
);
is $ast->type, 'exprseq';
ok $ast->type('exprseq');
ok not $ast->type('type');
ok not $ast->type('list');

$ast = PerlMaple::Expression->new('2,        3,4');
is $ast->expr, '2, 3, 4';

$ast = PerlMaple::Expression->new('2,        3,4', 1);
is $ast->expr, '2,        3,4';

$ast = PerlMaple::Expression->new('[7,8,9]');
@ops = $ast->ops;
is $ops[0]->expr, 7;
is $ops[1]->expr, 8;
is $ops[2]->expr, 9;

my $expr = PerlMaple::Expression->new('x^3+2*x-1');
is $expr->expr, 'x^3+2*x-1';
is $expr->type, '`+`';
my @a = $expr->ops;
ok @a;
my @b = map { $_->expr } @a;
cmp_deeply \@b, ['x^3', '2*x', '-1'];

is $a[0]->type, '`^`';
@b = map { $_->expr } $a[0]->ops;
cmp_deeply \@b, ['x', '3'];

is $a[1]->type, '`*`';
@b = map { $_->expr } $a[1]->ops;
cmp_deeply \@b, ['2', 'x'];
