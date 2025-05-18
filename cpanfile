requires 'Mouse';
requires 'Mouse::Util::TypeConstraints';
requires 'DBI';
requires 'Dotenv';
requires 'URI::db';
requires 'Path::Tiny';
requires 'Plack';
requires 'Plack::MIME';
requires 'Plack::Builder';
requires 'Plack::Request';
requires 'HTTP::Status';
requires 'JSON::MaybeXS';
requires 'Try::Tiny';
requires 'Module::Load';
requires 'Carp';
requires 'Exporter';
requires 'Test2::Bundle::More';
requires 'aliased';

# Dev dependencies
on 'develop' => sub {
    requires 'Carton';  # Include Carton itself as a development dependency
    requires 'Plack::App::Directory';  # For development server
    requires 'Plack::Middleware::Refresh';  # For auto-reloading during development
};