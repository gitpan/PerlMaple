use strict;
use warnings;
use inc::Module::Install;

name            ('PerlMaple');
version_from    ('lib/PerlMaple.pm');
abstract_from   ('lib/PerlMaple.pm');
author          ('Agent Zhang <agent2002@126.com>');
license         ('perl');

requires        ('Inline');

build_requires  ('Test::More');

WriteMakefile(
    OBJECT => 'PerlMaple$(OBJ_EXT) maplec$(LIB_EXT)',
);

&WriteAll();
