package JVRecipes::Endpoint::Healthcheck;

use Mouse;
with "JVRecipes::Role::Endpoint::Base";

sub run {
    my $self = shift;

    $self->send_response(content => "OK");
}

1;