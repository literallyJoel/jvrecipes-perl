package JVRecipes::Role::Router;

use Mouse::Role;
use JSON::MaybeXS;
use Try::Tiny;
use Plack::Request;
use Module::Load;


our $ROUTES = [];

has "prefix" => (is => "ro", isa => "Str", default => "");

sub group {
    my $self   = shift;
    my $prefix = shift;
    my $module = shift;

    load $module;

    my $router = $module->new(prefix => $self->prefix . $prefix);

    return $self;
}

sub get {
    my $self       = shift;
    my $path       = shift;
    my $controller = shift;

    $self->_add_route("GET", $path, $controller);

    return $self;
}

sub post {
    my $self       = shift;
    my $path       = shift;
    my $controller = shift;

    $self->_add_route("POST", $path, $controller);
    
    return $self;
}

sub put {
    my $self       = shift;
    my $path       = shift;
    my $controller = shift;

    $self->_add_route("PUT", $path, $controller);
    
    return $self;
}

sub delete {
    my $self       = shift;
    my $path       = shift;
    my $controller = shift;

    $self->_add_route("DELETE", $path, $controller);
    
    return $self;
}

sub any {
    my $self       = shift;
    my $path       = shift;
    my $controller = shift;

    $self->_add_route("ANY", $path, $controller);
    
    return $self;
}

sub _add_route {
    my $self       = shift;
    my $method     = shift;
    my $path       = shift;
    my $controller = shift;

    load $controller;
    
    push @$ROUTES, [
        $method, 
        $self->prefix . $path, 
        $controller,
    ];
}

sub handle {
    my $self = shift;
    my $env  = shift;

    my $request = Plack::Request->new($env);
    my $path    = $request->path_info;
    my $method  = $request->method;

    for my $route (@$ROUTES) {
        my ($route_method, $route_path, $controller_class) = @$route;

        next unless $route_method eq $method || $route_method eq "ANY";

        if ($route_path eq $path) {
            my $controller = $controller_class->new(
                request => $request,
                path_params => {}
            );
            return $controller->run();
        }

        if ($route_path =~ /\*$/) {
            my $prefix = $route_path;
            $prefix =~ s/\*$//;

            if ($path =~ /^$prefix/) {
                my $controller = $controller_class->new(
                    request => $request,
                    path_params => {}
                );
                return $controller->run();
            }
        }

        if ($route_path =~ /:/) {
            my @route_segments = split "/", $route_path;
            my @path_segments  = split "/", $path;

            next if @route_segments != @path_segments;

            my $matches = 1;
            my %params;

            for my $i (0..$#route_segments) {
                if( $route_segments[$i] =~ /^:(.+)$/) {
                    $params{$1} = $path_segments[$i];
                } elsif ($route_segments[$i] ne $path_segments[$i]) {
                    $matches = 0;
                    last;
                }
            }

            if ($matches) {
                my $controller = $controller_class->new(
                    request => $request,
                    path_params => \%params
                );
                return $controller->run();
            }
        }
    }

    return [
        404,
        ['Content-Type' => 'application/json'],
        [encode_json({ error => 'Not found' })]
    ];
}

sub clear_routes {
    @$ROUTES = ();
}

1;