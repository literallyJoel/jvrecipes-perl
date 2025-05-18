package JVRecipes::Routes::Static;

use Mouse;
with "JVRecipes::Role::Router";

use Path::Tiny;
use Plack::MIME;

sub BUILD {
    my $self = shift;

    $self->get("*", "JVRecipes::Endpoint::Static");
}

1;