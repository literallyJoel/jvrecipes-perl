use 5.020;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'JVRecipes',
    AUTHOR           => 'Developer <dev@example.com>',
    VERSION_FROM     => 'lib/JVRecipes/Routes/Base.pm',
    ABSTRACT         => 'JVRecipes Application',
    LICENSE          => 'mit',
    MIN_PERL_VERSION => '5.020',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    TEST_REQUIRES => {
        'Test2::Bundle::More' => '0',
    },
    PREREQ_PM => {
        'Mouse'                      => '0',
        'Mouse::Util::TypeConstraints' => '0',
        'DBI'                        => '0',
        'Dotenv'                     => '0',
        'URI::db'                    => '0',
        'Path::Tiny'                 => '0',
        'Plack'                      => '0',
        'Plack::MIME'                => '0',
        'Plack::Builder'             => '0',
        'Plack::Request'             => '0',
        'HTTP::Status'               => '0',
        'JSON::MaybeXS'              => '0',
        'Try::Tiny'                  => '0',
        'Module::Load'               => '0',
        'Carp'                       => '0',
        'Exporter'                   => '0',
        'aliased'                    => '0',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'JVRecipes-*' },
);
