package JVRecipes::User::Util;

use Mouse;
with qw(
    JVRecipes::Role::DAO::User
);

sub get_by_id {
    my $self = shift;
    my $id   = shift;

    return $self->user_dao->select(
        where => {
            id => $id
        }
    )->[0];
}

sub get_by_email {
    my $self  = shift;
    my $email = shift;

    return $self->user_dao->select(
        where => {
            email => $email
        }
    )->[0];
}

1;