package JVRecipes::Object::Database::Schema;

use Mouse;
use Mouse::Util::TypeConstraints;

class_type "JVRecipes::Object::Database::Schema";

has "tables"     => ( is => "ro", isa => "ArrayRef[JVRecipes::Object::Database::Table]", default => sub {[]});
has "query"      => ( is => "ro", isa => "Str", lazy_build => 1) ;
has "as_hashref" => ( is => "ro", isa => "HashRef[JVRecipes::Object::Database::Table]", lazy_build => 1 );

sub _build_query {
    my $self = shift;

    my @queries = map { $_->query } $self->tables->@*;

    return join "\n\n", @queries;
}

sub _build_as_hashref {
    my $self = shift;
    my $tables = $self->tables;

    return { map {$_->name => $_} @$tables };
}

__PACKAGE__->meta->make_immutable;

1;