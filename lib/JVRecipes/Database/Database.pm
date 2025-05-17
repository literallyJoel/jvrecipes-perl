package JVRecipes::Database::Database;

use Mouse;
use DBI;

has 'dbh' => (is => "ro", isa => "DBI::db", lazy_build => 1);

sub _build_dbh {
    my $self = shift;

    my $dsn = $ENV{DATABASE_URL};

    die "Database URL is not set" unless $dsn;

    $dsn =~ s/^postgres:/dbi:Pg:/;
    return DBI->connect($dsn, '', '', { RaiseError => 1, AutoCommit => 1 });
}

1;