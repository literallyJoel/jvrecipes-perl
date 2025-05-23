package JVRecipes::User::Password;

use Mouse;
with "JVRecipes::Role::DAO::User";

use Crypt::Argon2 qw(argon2id_pass argon2_verify);
use MIME::Base64 qw(encode_base64);
use Crypt::URandom qw(urandom);

sub with_password_hash {1};

sub hash {
    my $self     = shift;
    my $password = shift // $self;

    my $salt = encode_base64(urandom(16), '');

    return argon2_idpass(
        $password,
        $salt,
        3,
        1024,
        1
    );
}

sub verify {
    my %args = @_;

    my $hash     = $args{hash};
    my $password = $args{password};

    return argon2_verify($hash, $password);
}

sub is_valid {
    my $self     = shift;
    my $password = shift // $self;

    return length($password) > 8;
}

sub get_by_user_id {
    my $self = shift;
    my $id   = shift;

    my $user_select = $self->user_dao->select(
        where => {"p.id" => $id}
    );

    return unless $user_select;

    my $user = $user_select->[0];

    return $user->{pw_hash};
}

1;