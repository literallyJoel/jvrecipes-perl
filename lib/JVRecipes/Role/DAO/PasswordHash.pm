package JVRecipes::Role::DAO::PasswordHash;

use Mouse::Role;

use JVRecipes::DAO::PasswordHash;

has "password_hash_dao" => ( is => "ro", isa => "JVRecipes::DAO::PasswordHash", lazy_build => 1);

sub _build_password_hash_dao {
    my $self = shift;

    return JVRecipes::DAO::PasswordHash->new(
        dbh => $self->dbh,
    );
}

1;