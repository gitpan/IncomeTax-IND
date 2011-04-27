use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'IncomeTax::IND',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/IncomeTax/IND.pm',
    ABSTRACT_FROM => 'lib/IncomeTax/IND.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'IncomeTax-IND-*' },
    PREREQ_PM     => {
        'Test::More' => 0,
        'Readonly'   => 0,
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);