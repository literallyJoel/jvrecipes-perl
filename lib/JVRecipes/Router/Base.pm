package JVRecipes::Router::Base;

use Mouse;
use JSON::MaybeXS;
use Try::Tiny;
use Plack::Request;
use Module::Load;

has "prefix" => ( is => "ro", isa => "Str", default => "");
has "routes" => ( is => "rw", isa => "ArrayRef", default => sub{[]});

sub group {
    my $self   = shift;
    my $prefix = shift;
    my $module = shift;

    load $module;
    die "$module is not a valid router instance"
        unless $module->can("new");
    
    my $router = $module->new(prefix => $self->prefix . $prefix);

    die "$router is not a valid router instance"
         unless $router->has("_router");

    push $self->routes->@*, $router->_router->routes->@*;

    return $self;
}

sub get    {shift->_add_route("GET", @_)}
sub post   {shift->_add_route("POST", @_)}
sub put    {shift->_add_route("PUT", @_)}
sub delete {shift->_add_route("DELETE", @_)}
sub any    {shift->_add_route("ANY", @_)}

sub _add_route {
    my $self       = shift;
    my $method     = shift;
    my $path       = shift;
    my $controller = shift;

    load $controller;

    die "$controller is not a valid controller instance"
        unless $controller->can("new") && $controller->can("run");

    push $self->routes->@*, [
        $method,
        $self->prefix . $path,
        $controller,
    ];

    return $self;
}

sub handle {
    my $self = shift;
    my $env  = shift;
    
    my $request = Plack::Request->new($env);
    my $path    = $request->path_info;
    my $method  = $request->method;

    my $wrong_method = 0;
    
    for my $route ($self->routes->@*) {
        my ($route_method, $route_path, $controller) = @$route;
        
        die "$controller is not a valid controller instance"
            unless $controller->can("new") && $controller->can("run");

        if($route_path eq $path && $route_method ne $method && $route_method ne "ANY") {
            $wrong_method = 1;
            next;
        }

        next unless $route_method eq $method || $route_method eq "ANY";
        
        return $self->_invoke(
            controller => $controller,
            request    => $request,
            route_path => $route_path
        ) if $route_path eq $path;
        
        if ($route_path =~ /\*$/) {
            my $prefix = $route_path;
            $prefix =~ s/\*$//;

            return $self->_invoke(
                controller => $controller,
                request    => $request,
                route_path => $route_path
            ) if $path =~ /^prefix/;
        }

        if ($route_path =~ /:/) {
            my @route_segments = split "/", $route_path;
            my @path_segments  = split "/", $path;

            next if @route_segments != @path_segments;

            my $matches = 1;

            my %params;

            for my $i (0..$#route_segments) {
                if($route_segments[$i] =~ /^:(.+)$/) {
                    $params{$1} = $path_segments[$i];
                } elsif ($route_segments[$i] ne $path_segments[$i]) {
                    $matches = 0;
                    last;
                }
            }

            return $self->_invoke(
                controller  => $controller,
                request     => $request,
                path_params => \%params,
                route_path  => $route_path,
            ) if $matches;
        }
    }

    # If no route matches, return a 404 response
    return [
        404,
        ["Content-Type" => "application/json"],
        [encode_json({error => "Not Found"})]
    ];
}

sub _invoke {
    my $self        = shift;
    my %args        = @_;
    my $controller  = $args{controller};
    my $request     = $args{request};
    my $path_params = $args{path_params} || {};
    my $route_path  = $args{route_path};

    my $response;

    eval {
        my $instance = $controller->new(request => $request, path_params => $path_params);
        $response = $instance->run;
    };
   
    if($@) {
        warn "Error handling request to $route_path: $@";

        return [
            500,
            ["Content-Type", "application/json"],
            [encode_json({errors => [500 => "Internal Server Error"]})]
        ];
    }

    return $response;
}

sub clear_routes {
    my $self = shift;

    $self->routes->@* = ();
}

1;