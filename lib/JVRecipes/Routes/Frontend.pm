package JVRecipes::Routes::Frontend;

use Mouse;
use Path::Tiny;
use Plack::MIME;

with "JVRecipes::Role::Router";

sub BUILD {
    my $self = shift;

    $self->get("*", "JVRecipes::Endpoint::Frontend");
}

1;