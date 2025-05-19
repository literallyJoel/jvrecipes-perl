package JVRecipes::Object::Database::Table;

use Mouse;
use Mouse::Util::TypeConstraints;

class_type "JVRecipes::Object::Database::Table";

has name        => ( is => "ro", isa => "Str", required => 1);
has columns     => ( is => "ro", isa => "ArrayRef[JVRecipes::Object::Database::Column]", required => 1 );
has constraints => ( is => "ro", isa => "ArrayRef[Str]" );
has query       => ( is => "ro", isa => "Str", lazy_build => 1);
has primary_key => ( is => "ro", isa => "Str", lazy_build => 1);

sub _build_query {
    my $self = shift;

    my @column_definitions = map { $_->query} $self->columns->@*;

    push @column_definitions, $self->constraints->@* if $self->constraints;

    my $columns = join ",\n", @column_definitions;

    return "CREATE TABLE IF NOT EXISTS " . $self->name . " (\n $columns\n);";
}

sub _build_primary_key {
    my $self = shift;

    return [grep {$_->primary_key} $self->columns->@*];
}

__PACKAGE__->meta->make_immutable;

1;