package JVRecipes::User::Util;

use Mouse;
with qw(
    JVRecipes::Role::DAO::User
);

sub get_by_id {
    my $self = shift;
    my $id   = shift;

    return unless defined $id && $id =~ /^\d+$/;

    my $results = $self->user_dao->select(
        where => {
            id => $id
        }
    );

    return $results && @$results ? $results->[0] : undef;
}

sub get_by_email {
    my $self  = shift;
    my $email = shift;

    return unless defined $email && $email =~ /\S+\@\S+/;

    my $results = $self->user_dao->select(
        where => {
            email => $email
        }
    );

    return $results && @$results ? $results->[0] : undef;
}

1;