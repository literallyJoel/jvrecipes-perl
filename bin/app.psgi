use strict;
use warnings;
use lib 'lib';
use Plack::Builder;

use JVRecipes::Routes::Base;
use JVRecipes::Database::Schema;

my $routes = JVRecipes::Routes::Base->new;
my $schema = JVRecipes::Database::Schema->new;

my $app = sub {
    my $env = shift;
    return $routes->handle($env);
};


builder {
    $schema->generate;
    enable "Plack::Middleware::ContentLength";
    enable "Plack::Middleware::CrossOrigin", origins => "*";
    $app;
};