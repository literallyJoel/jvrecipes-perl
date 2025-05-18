package JVRecipes::Endpoint::Static;

use Mouse;
with "JVRecipes::Role::Endpoint::Base";

use Path::Tiny qw(path);
use Plack::MIME;

sub run {
    my $self = shift;

    my $base_dir = path("frontend/dist");

    if ($self->request_path =~ m{^/assets/(.+)}) {
        my $asset_path = $1;

        my $file_path = $base_dir->child("assets", $asset_path);

        unless ($file_path->exists && $file_path->is_file) {
            return $self->not_found;
        }

        my $content = $file_path->slurp_raw;
        my $content_type = Plack::MIME->mime_type($file_path->basename) || "application/octet-stream";

        return [
            200,
            ["Content-Type" => $content_type],
            [$content],
        ];
    }

    my $file_path = $base_dir->child("index.html");
    unless ($file_path->exists && $file_path->is_file) {
        return $self->not_found;
    }

    my $content = $file_path->slurp_raw;
    my $content_type = "text/html";

    return [
        200,
        ["Content-Type" => $content_type],
        [$content],
    ];
}

1;
