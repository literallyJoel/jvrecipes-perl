package JVRecipes::Routes::API::Auth;

use Mouse;
with "JVRecipes::Role::Router";

sub BUILD {
    my $self = shift;

    $self->post("/login", "JVRecipes::Endpoint::Auth::Login");
}

1;