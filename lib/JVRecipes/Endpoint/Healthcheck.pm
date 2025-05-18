package JVRecipes::Endpoint::Healthcheck;

use Mouse;
with "JVRecipes::Role::Endpoint::Base";

sub run {
    my $self = shift;

    return $self->send_response(content => {message => "OK from Healthcheck!!"});
}

1;