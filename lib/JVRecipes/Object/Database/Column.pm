package JVRecipes::Object::Database::Column;

use Mouse;
use Mouse::Util::TypeConstraints;

class_type "JVRecipes::Object::Database::Column";

has name        => ( is => "ro", isa => "Str", required => 1 );
has type        => ( is => "ro", isa => "Str", required => 1 );
has constraints => ( is => "ro", isa => "ArrayRef[Str]" );
has primary_key => ( is => "ro", isa => "Int", default => 0 );
has nullable    => ( is => "ro", isa => "Int" );
has default     => ( is => "ro", isa => "Str" );
has query       => ( is => "ro", isa => "Str", lazy_build => 1 );

sub _build_query {
    my $self = shift;

    my $query = $self->name . " " . $self->type;
    $query .= " NOT NULL"                            unless $self->nullable;
    $query .= " DEFAULT ". $self->default            if $self->default;
    $query .= " PRIMARY KEY"                         if $self->primary_key;
    $query .= " " . join " ", $self->constraints->@* if $self->constraints;
    return $query;
}

__PACKAGE__->meta->make_immutable;

1;