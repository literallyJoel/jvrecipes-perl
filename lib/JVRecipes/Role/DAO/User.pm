package JVRecipes::Role::DAO::User;

use Mouse::Role;

use JVRecipes::DAO::User;

has "user_dao" => ( is => "ro", isa => "JVRecipes::DAO::User", lazy_build => 1);
has "with_password" => ( is => "ro", isa => "Bool", default => 0 );

sub _build_user_dao {
    my $self = shift;

    return JVRecipes::DAO::User->new(
        dbh => $self->dbh,
        with_password_hash => $self->with_password,
    );
}

1;