package JVRecipes::Routes::Static;

use Mouse;
use Path::Tiny;
use Plack::MIME;

with "JVRecipes::Role::Router";

sub BUILD {
    my $self = shift;

    $self->get("*", "JVRecipes::Endpoint::Static");
}

1;