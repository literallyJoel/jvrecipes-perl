package JVRecipes::DAO::User;

use Mouse;
extends "JVRecipes::DAO::Base";

has "with_password_hash" => ( is => "ro", isa => "Bool", default => 0);

sub table_name {"user"};

sub select {
    my $self  = shift;
    my %args  = @_;
    my $where = $args{where};

    return $self->_select(%args)
        unless $self->with_password_hash;

    my $sql = "SELECT " . join(", ", map {"u.$_"} $self->columns->@*) . ", pw.hash as pw_hash";
    $sql   .= " FROM " . $self->table_name . " u ";
    $sql   .= qq{
                JOIN auth_identities ai
                  ON ai.user_id = u.id
                JOIN password_hashes pw
                  ON pw.auth_identity_id = ai.id
              };

    my ($where_sql, $where_bind) = $self->_build_where($where);

    $sql .= " $where_sql";

    return $self->execute($sql, "READ", @$where_bind);
}

1;