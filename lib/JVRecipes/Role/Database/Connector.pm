package JVRecipes::Role::Database::Connector;

use Mouse::Role;

use JVRecipes::Database::Database;


has 'database' => ( is => "ro", isa => "JVRecipes::Database::Database", lazy_build => 1);
has 'dbh'      => ( is => "ro", isa => "DBI::db", lazy_build => 1);

sub _build_database {
    return JVRecipes::Database::Database->new;
}

sub _build_dbh {
    my $self = shift;

    return $self->database->dbh;
}

1;