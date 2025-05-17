package JVRecipes::Role::Endpoint::Base;

use Mouse::Role;
use JSON::MaybeXS;
use HTTP::Status qw(:constants);
use Try::Tiny;

has body         => (is => "ro", lazy_build => 1);
has query_params => (is => "ro", isa => "HashRef", lazy_build => 1);
has path_params  => (is => "ro", isa => "HashRef", lazy_build => 1);
has request_path => (is => "ro", isa => "Str", lazy_build => 1);
has request      => (is => "ro", lazy_build => 1);

sub _build_body {
    my $self = shift;

    # Guard against undefined request
    return {} unless $self->request;

    my $content = $self->request->content;

    return {} unless $content;

    try {
        my $decoded = decode_json($content);
        return $decoded;
    } catch {
        return {};
    }
}

sub _build_query_params {
    my $self = shift;

    return {} unless $self->request;

    return $self->request->query_parameters->as_hashref;
}

sub _build_path_params {
    my $self = shift;

    return $self->{path_params} || {};
}

sub _build_request_path {
    my $self = shift;

    return "/" unless $self->request;

    return $self->request->path_info || "/";
}

sub BUILD {
    my ($self, $args) = @_;

    if (defined $args->{request}) {
        $self->{request} = $args->{request};
    }

    if (defined $args->{path_params}) {
        $self->{path_params} = $args->{path_params};
    }
}


around run => sub {
    my $run  = shift;
    my $self = shift;
    my @args = @_;

    return $self->$run(@args) unless $self->can("validate");

    my ($valid, $errors) = $self->validate(
        body         => $self->body,
        query_params => $self->query_params,
        path_params  => $self->path_params,
    );

    return $self->$run(@args) if $valid;

    $self->bad_request($errors);
};

sub send_response {
    my $self = shift;
    my %args = @_;

    my $status_code = $args{status_code} || 200;
    my $content     = $args{content};

    return [
        $status_code,
        ["Content-Type", "application/json"],
        [encode_json($content)],
    ];
}

sub not_found {
    return [
        404,
        ["Content-Type", "application/json"],
        [encode_json({error => "Not Found"})],
    ];
}

sub bad_request {
    my $self = shift;
    my %errors = @_;

    return [
        400,
        ["Content-Type", "application/json"],
        [encode_json({errors => \%errors})],
    ];
}

sub unauthorized {
    return [
        401,
        ["Content-Type", "application/json"],
        [encode_json({error => "Unauthorized"})]
    ];
}

1;