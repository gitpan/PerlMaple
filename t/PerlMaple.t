#: PerlMaple.t
#: 2005-11-14 2005-11-14

use strict;
use warnings;

use Test::More tests => 11;
BEGIN { use_ok('PerlMaple') }

my $maple = PerlMaple->new;
ok $maple;
ok !defined $maple->error;
isa_ok($maple, 'PerlMaple');

my $ans = $maple->eval('eval(int(2*x^3,x), x=2);');
is $ans, 8;
ok !defined $maple->error;

$ans = $maple->eval("eval(int(2*x^3,x), x=2)  \n \n\r");
is $ans, 8;
ok !defined $maple->error;

$ans = $maple->eval("eval(int(2*x^3,x), x=2");
ok !defined $ans;
ok $maple->error;
like $maple->error, qr/[a-z]+/i;
