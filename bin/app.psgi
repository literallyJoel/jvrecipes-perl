use strict;
use warnings;
use lib 'lib';
use Plack::Builder;

use JVRecipes::Routes::Base;

my $routes = JVRecipes::Routes::Base->new;

my $app = sub {
    my $env = shift;
    return $routes->handle($env);
};

builder {
    enable "Plack::Middleware::ContentLength";
    enable "Plack::Middleware::CrossOrigin", origins => "*";
    $app;
};