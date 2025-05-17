package JVRecipes::Role::Router;

use Mouse::Role;
use JVRecipes::Router::Base;

has '_router' => ( is => 'ro', isa => 'JVRecipes::Router::Base', lazy_build => 1 );


sub _build__router {
    return JVRecipes::Router::Base->new;
}

sub group  {shift->_router->group(@_)}
sub get    {shift->_router->get(@_)}
sub post   {shift->_router->post(@_)}
sub put    {shift->_router->put(@_)}
sub delete {shift->_router->delete(@_)}
sub any    {shift->_router->any(@_)}
sub handle {shift->_router->handle(@_)}


1;
