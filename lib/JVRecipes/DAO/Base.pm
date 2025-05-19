package JVRecipes::DAO::Base;

use Mouse;
use Mouse::Util::TypeConstraints;
with "JVRecipes::Role::Database::Connector";

use Carp qw(croak);
use Try::Tiny;
use JSON::MaybeXS;

my $stored_schema;

has table_name   => ( is => "ro", isa => "Str", required => 1 );
has primary_key  => ( is => "ro", isa => "Str", lazy_build => 1 );
has table_schema => ( is => "ro", isa => "Str", lazy_build => 1 );
has columns      => ( is => "ro", isa => "ArrayRef[str]", lazy_build => 1 );

sub select {
    my $self = shift;
    my %args = @_;

    my $where = $args{where};

    my ($where_sql, $where_bind) = $self->_build_where($where);

    my $sql = "SELECT ";
    $sql .= join ", ", $self->columns->@*;
    $sql .= " FROM " . $self->table_name;
    $sql .= " $where_sql";

    my $result;
    try {
        $result = $self->dbh->selectall_arrayref(
            $sql,
            { Slice => {} },
            @$where_bind
        );
    } catch {
        croak "DB SELECT failed: $_";
    };

    return $result;
}

sub insert {
    my $self = shift;
    my $obj  = shift;

    my @columns = $self->columns->@*;
    my @insert_cols = grep { exists $obj->{$_} } @columns;
    croak "No valid columns to insert" unless @insert_cols;

    my @placeholders = map {"?"} @insert_cols;
    my @bind = @{$obj}{@insert_cols};

    my $sql = "INSERT INTO " . $self->table_name .
              " (" . join(", ", @insert_cols) . ") VALUES (" .
              join(", ", @placeholders) . ") RETURNING " . $self->primary_key;

    my $last_id;
    try {
        my $sth = $self->dbh->prepare($sql);
        $sth->execute(@bind);
        ($last_id) = $sth->fetchrow_array;
    } catch {
        croak "DB INSERT failed: $_";
    };

    return $last_id;
}

sub update {
    my $self = shift;
    my $obj  = shift;
    my $where = shift;

    croak "Update requires a where clause" unless $where && %$where;

    my @columns = $self->columns->@*;
    my @update_cols = grep { exists $obj->{$_} } @columns;
    croak "No valid columns to update" unless @update_cols;

    my @set_sql = map { "$_ = ?" } @update_cols;
    my @bind = @{$obj}{@update_cols};

    my $sql = "UPDATE " . $self->table_name . " SET " . join(", ", @set_sql);

    my ($where_sql, $where_bind) = $self->_build_where($where);
    $sql .= " $where_sql";
    push @bind, @$where_bind;

    try {
        my $sth = $self->dbh->prepare($sql);
        return $sth->execute(@bind)->rows;
    } catch {
        croak "DB UPDATE failed: $_";
    };
}

sub _build_where {
    my $self  = shift;
    my $where = shift || {};

    my @where_args;
    my @where_bind;

    my %ops = (
        lt  => '<',
        lte => '<=',
        gt  => '>',
        gte => '>=',
        ne  => '!=',
    );

    for my $col (keys %$where) {
        my $condition = $where->{$col};

        if ($condition =~ /^\[([^\]]*)\]\s*(.*)$/) {
            my $operator = $1;
            my $value    = $2;

            my $sql_operator = $ops{$operator};
            unless ($sql_operator) {
                croak "Unknown operator $operator in where clause";
            }

            push @where_args, "$col $sql_operator ?";
            push @where_bind, $value;
        } else {
            push @where_args, "$col = ?";
            push @where_bind, $condition;
        }
    }

    my $where_sql = @where_args ? "WHERE " . join(" AND ", @where_args) : "";

    return ($where_sql, \@where_bind);
}

sub _get_schema {
    return $stored_schema if $stored_schema;

    require JVRecipes::Database::Schema;
    $stored_schema = JVRecipes::Database::Schema->new->schema;

    return $stored_schema;
}

sub _build_table_schema {
    my $self = shift;

    my $schema = _get_schema;

    my $table = $schema->as_hashref->{$self->table_name};

    croak "No " . $self->table_name . " found in schema" unless $table;

    return $table;
}

sub _build_primary_key {
    return shift->table_schema->primary_key;
}

sub _build_columns {
    return [map {$_->name} shift->table_schema->columns];
}

1;
