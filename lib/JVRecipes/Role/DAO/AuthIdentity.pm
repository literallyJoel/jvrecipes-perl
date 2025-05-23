package JVRecipes::Role::DAO::AuthIdentity;

use Mouse::Role;

use JVRecipes::DAO::AuthIdentity;

has "auth_identity_dao" => ( is => "ro", isa => "JVRecipes::DAO::AuthIdentity", lazy_build => 1);

sub _build_auth_identity_dao {
    my $self = shift;

    return JVRecipes::DAO::AuthIdentity->new(
        dbh => $self->dbh,
    );
}

1;