package JVRecipes::Object::Database::Schema;

use Mouse;
use Mouse::Util::TypeConstraints;

class_type "JVRecipes::Object::Database::Schema";

has "tables"     => ( is => "ro", isa => "ArrayRef[JVRecipes::Object::Database::Table]", default => sub {[]});
has "query"      => ( is => "ro", isa => "Str", lazy_build => 1) ;
has "_table_map" => ( is => "ro", isa => "HashRef[JVRecipes::Object::Database::Table]", lazy_build => 1 );

sub _build_query {
    my $self = shift;

    my @queries = map { $_->query } $self->tables->@*;

    return join "\n\n", @queries;
}

sub _build__table_map {
    my $self = shift;
    my $tables = $self->tables;

    my %table_map = map {$_->name => $_} @$tables;

    return \%table_map;
}

__PACKAGE__->meta->make_immutable;

1;