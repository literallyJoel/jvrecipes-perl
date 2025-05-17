package JVRecipes::Endpoint::Auth::Login;

use Mouse;
with "JVRecipes::Role::Endpoint::Base";

sub run {
    my $self = shift;

    return $self->send_response(
        content => {message => "Hello from login"}
    );
}

1;