use strict;
use warnings;
use inc::Module::Install;

name            ('PerlMaple');
version_from    ('lib/PerlMaple.pm');
abstract_from   ('lib/PerlMaple.pm');
author          ('Agent Zhang <agent2002@126.com>');
license         ('perl');

requires        ('Carp');

build_requires  ('Test::More');
build_requires  ('Test::Deep');

WriteMakefile(
    OBJECT => 'PerlMaple$(OBJ_EXT) maplec$(LIB_EXT)',
);

&WriteAll();

warn <<'_EOC_';

      *** ------------------------------------------------- ***
      ***                                                   ***
      ***   Make sure you have Maple 9 or higher installed  ***
      ***   and have maplec.h in INC, maplec.lib            ***
      ***   (or maplec.a, etc.) in LIB                      ***
      ***                                                   ***
      *** ------------------------------------------------- ***

_EOC_
