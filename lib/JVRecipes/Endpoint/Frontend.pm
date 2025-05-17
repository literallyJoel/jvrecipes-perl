package JVRecipes::Endpoint::Frontend;

use Mouse;
use Path::Tiny;
use Plack::MIME;

with "JVRecipes::Role::Endpoint::Base";

sub run {
    my $self = shift;

    my $base_dir = path("frontend/dist");

    my $file_path = $base_dir->child("index.html");

    $self->not_found unless $file_path->exists;

    my $content = $file_path->slurp_raw;
    my $content_type = Plack::MIME->mime_type($file_path) || 'text/plain';

    return [
        200,
        ["Content-Type" => $content_type],
        [$content],
    ];
}

1;

