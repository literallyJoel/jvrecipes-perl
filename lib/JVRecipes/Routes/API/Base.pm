package JVRecipes::Routes::API::Base;

use Mouse;
with "JVRecipes::Role::Router";

sub BUILD {
    my $self = shift;

    $self->get("/healthcheck", "JVRecipes::Endpoint::Healthcheck");

    $self->group("/auth", "JVRecipes::Routes::API::Auth");
}

1;