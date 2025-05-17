package JVRecipes::Routes::Base;

use Mouse;

with "JVRecipes::Role::Router";

sub BUILD {
    my $self = shift;

    $self->group("/api", "JVRecipes::Routes::API::Base");
    $self->group("/", "JVRecipes::Routes::Frontend");
}

1;