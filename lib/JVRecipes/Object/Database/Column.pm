package JVRecipes::Object::Database::Column;

use Mouse;
use Mouse::Util::TypeConstraints;

class_type "JVRecipes::Object::Database::Column";

has name        => ( is => "ro", isa => "Str", required => 1 );
has type        => ( is => "ro", isa => "Str", required => 1);
has constraints => ( is => "ro", isa => "ArrayRef[Str]");
has nullable    => ( is => "ro", isa => "Int");
has default     => ( is => "ro", isa => "Str");
has query       => ( is => "ro", isa => "Str", lazy_build => 1);

sub _build_query {
    my $self = shift;

    my $query = $self->name . " " . $self->type;
    $query .= $self->nullable    ? ""                                     : "NOT NULL";
    $query .= $self->default     ? " DEFAULT ". $self->default            : "";
    $query .= $self->constraints ? " " . join " ", $self->constraints->@* : "";

    return $query;
}

__PACKAGE__->meta->make_immutable;

1;