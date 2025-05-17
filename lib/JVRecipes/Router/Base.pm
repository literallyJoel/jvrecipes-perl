package JVRecipes::Router::Base;

use Mouse;
use JSON::MaybeXS;
use Try::Tiny;
use Plack::Request;
use Module::Load;
use JVRecipes::Router::Node;

has "prefix"  => ( is => "ro", isa => "Str", default => "" );
has "_routes" => ( is => "ro", isa => "JVRecipes::Router::Node", default => sub {
    JVRecipes::Router::Node->new;
});

sub group {
    my $self   = shift;
    my $prefix = shift;
    my $module = shift;

    load $module;

    die "$module is not a valid router instance"
        unless $module->can("new");
    
    my $router = $module->new(prefix => $self->prefix . $prefix);

    die "$router is not a valid router instance"
        unless $router->can("_router");
    
    for my $method (qw(GET POST PUT DELETE ANY PATCH)) {
        $self->_child_route($router->_router, $method);
    }

    return $self;
}

sub get    {shift->_add_route("GET", @_)}
sub post   {shift->_add_route("POST", @_)}
sub put    {shift->_add_route("PUT", @_)}
sub delete {shift->_add_route("DELETE", @_)}
sub any    {shift->_add_route("ANY", @_)}
sub patch  {shift->_add_route("PATCH", @_)}

sub handle {
    my $self = shift;
    my $env  = shift;

    my $request = Plack::Request->new($env);
    my $path    = $request->path_info;
    my $method  = $request->method;

    my @segments;
    @segments = grep { $_ ne ""} split "/", $path unless $path eq "/";
    @segments = ("") if $path eq "/";

    my ($controller, $path_params, $has_other_methods) =
        $self->_routes->find_route(
            method        => $method,
            path_segments => \@segments,
        );
    
    return $self->_invoke(
        controller  => $controller,
        request     => $request,
        path_params => $path_params,
        route_path  => $path,
    ) if $controller;

    my $response_code = $has_other_methods ? 405 : 404;
    my $error_message = $has_other_methods ? "Method Not Allowed" : "Not Found";

    return [
        $response_code,
        ["Content-Type" => "application/json"],
        [encode_json({errors => [{$response_code => $error_message}]})],
    ];
}

sub _child_route {
    my $self   = shift;
    my $router = shift;
    my $method = shift;

    $self->_find_route(
        node => $router->_routes,
        method => $method
    );
}

sub _find_route {
        my $self = shift;
        my %args = @_;

        my $node   = $args{node};
        my $prefix = $args{prefix} || "";
        my $method = $args{method};

        if(exists $node->handlers->{$method}) {
            my $controller = $node->handlers->{$method};
            my $path = $prefix || "/";

            $self->_add_route_to_tree(
                method     => $method,
                path       => $path,
                controller => $controller
            );
        }

        for my $key (keys $node->children->%*) {
            my $child      = $node->children->{$key};
            my $new_prefix = $prefix ? "$prefix/$key" : "/$key";
            $self->_find_route(
                node   => $child,
                prefix => $new_prefix,
                method => $method,
            );
        }

        if($node->wildcard) {
            my $new_prefix = $prefix ? "$prefix/*" : "/*";
            if (exists $node->wildcard->handlers->{$method}) {
                my $controller = $node->wildcard->handlers->{$method};
                $self->_add_route_to_tree(
                    method     => $method,
                    path       => $new_prefix, 
                    controller => $controller
                );
            }
        }
}

sub _add_route {
    my $self       = shift;
    my $method     = shift;
    my $path       = shift;
    my $controller = shift;

    load $controller;
    die "$controller is not a valid controller instance"
        unless $controller->can("new") && $controller->can("run");
    
    $self->_add_route_to_tree(
        method     => $method, 
        path       => $self->prefix . $path,
        controller => $controller
    );

    return $self;
}

sub _add_route_to_tree {
    my $self = shift;
    my %args = @_;

    my $method     = $args{method};
    my $path       = $args{path};
    my $controller = $args{controller};

    my @segments;
    @segments = grep { $_ ne ""} split "/", $path unless $path eq "/";
    @segments = ("") if $path eq "/";

    $self->_routes->add_route(
        method        => $method,
        path_segments => \@segments,
        controller    => $controller,
    );
}

sub _invoke {
    my $self = shift;
    my %args = @_;

    my $controller  = $args{controller};
    my $request     = $args{request};
    my $path_params = $args{path_params} || {};
    my $route_path  = $args{route_path};

    my $response;

    try {
        my $instance = $controller->new(request => $request, path_params => $path_params);
        $response    = $instance->run;
    } catch {
        warn "Error handling request to $route_path: $_";
        return [
            500,
            ["Content-Type" => "application/json"],
            [encode_json({errors => [{500 => "Internal Server Error"}]})]
        ];
    };

    return $response;
}

1;