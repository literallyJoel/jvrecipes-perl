package JVRecipes::User::Create;

use Mouse;
with qw(
    JVRecipes::Role::DAO::User
    JVRecipes::Role::DAO::AuthIdentity
    JVRecipes::Role::DAO::PasswordHashes
);

use JVRecipes::User::Util;
use JVRecipes::User::Password;

sub create {
    my $self = shift;
    my %args = @_;

    my $first_name = $args{first_name};
    my $last_name  = $args{last_name};
    my $email      = $args{email};
    my $password   = $args{password};

    my $util = JVRecipes::User::Util->new;

    my $existing = $util->get_by_email($email);

    return (0, "already_exists") if $existing;

    my $hashed_pw = JVRecipes::User::Password::hash($password);

    # todo sort out transactions
    my $user_id = $self->user_dao->insert(
        email      => $email,
        first_name => $first_name,
        last_name  => $last_name,
    )->[0];

    return (0, "user_insert_failed") unless $user_id;

    my $auth_identity_id = $self->auth_identity_dao->insert(
        user_id     => $user_id,
        provider    => "local",
        provider_id => $user_id,
    );

    # rollback

    return (0, "auth_identity_insert_failed") unless $auth_identity_id;

    my $pw_hash_id = $self->password_hash_dao->insert(
        auth_identity_id => $auth_identity_id,
        hash             => $hashed_pw,
    );

    # rollback

    return (0, "password_hash_insert_failed") unless $pw_hash_id;

    return (1, $user_id);
}

1;