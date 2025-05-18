package JVRecipes::Database::Database;

use Mouse;

use DBI;
use Dotenv;
use URI::db;

Dotenv->load(".env") if -e ".env";

has 'dbh' => (is => "ro", isa => "DBI::db", lazy_build => 1);

sub _build_dbh {
    my $self = shift;

    my $url = $ENV{DATABASE_URL};
    die "Database URL not set" unless $url;

    my $uri = URI::db->new($url);

    my $dbname   = $uri->dbname;
    my $host     = $uri->host;
    my $port     = $uri->port || 5432;
    my $user     = $uri->user;
    my $password = $uri->password;
    my %query    = $uri->query_form;

    my $dsn = "dbi:Pg:dbname=$dbname;host=$host;port=$port";
    $dsn .= ";$_=$query{$_}" for keys %query;

    return DBI->connect($dsn, $user, $password, { RaiseError => 1, AutoCommit => 1 });
}

1;