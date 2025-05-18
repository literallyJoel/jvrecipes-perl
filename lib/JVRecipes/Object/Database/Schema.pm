package JVRecipes::Object::Database::Schema;

use Mouse;
use Mouse::Util::TypeConstraints;

class_type "JVRecipes::Object::Database::Schema";

has "tables"  => ( is => "ro", isa => "ArrayRef[JVRecipes::Object::Database::Table]", default => sub {[]});
has "query"   => ( is => "ro", isa => "Str", lazy_build => 1) ;


sub _build_query {
    my $self = shift;

    my @queries = map { $_->query } $self->tables->@*;

    return join "\n\n", @queries;
}


__PACKAGE__->meta->make_immutable;

1;