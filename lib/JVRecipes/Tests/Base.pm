package JVRecipes::Tests::Base;

use strict;
use warnings;

use Exporter 'import';
use Test2::Bundle::More ();

my @test2_exports = @Test2::Bundle::More::EXPORT;
Test2::Bundle::More->import(@test2_exports);

our @EXPORT = (
    @test2_exports,
);

1;
