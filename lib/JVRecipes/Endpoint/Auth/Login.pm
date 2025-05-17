package JVRecipes::Endpoint::Auth::Login;

use Mouse;
with "JVRecipes::Role::Endpoint::Base";

sub run {
    my $self = shift;

    use Data::Dumper;
    warn Dumper $self->body;

    return $self->send_response(
        content => {message => "OK"}
    );
}

1;