package JVRecipes::Router::Node;

use Mouse;
use Carp qw(croak);

has "segment"    => ( is => "ro", isa => "Str", default => "" );
has "children"   => ( is => "ro", isa => "HashRef", default => sub{ {} } );
has "param_name" => ( is => "ro", isa => "Maybe[Str]", default => undef );
has "handlers"   => ( is => "ro", isa => "HashRef", default => sub{ {} } );
has "wildcard"   => ( is => "rw", isa => "Maybe[JVRecipes::Router::Node]", default => undef );

sub add_route {
    my $self = shift;
    my %args = @_;

    my $method        = $args{method};
    my $path_segments = $args{path_segments};
    my $controller    = $args{controller};

    return $self->_add_handler($method, $controller)
        unless @$path_segments;
    
    my $segment = shift @$path_segments;

    if($segment eq "*") {
        croak "Wildcard must be final segment" if @$path_segments;

        $self->wildcard(JVRecipes::Router::Node->new(segment => "*"))
            unless $self->wildcard;
        
        $self->wildcard->_add_handler($method, $controller);
        return;
    }

    if($segment =~ /^:(.+)$/) {
        my $param_name = $1;

        $self->children->{$segment} = JVRecipes::Router::Node->new(
            segment    => $segment,
            param_name => $param_name,
        ) unless exists $self->children->{$segment};

        $self->children->{$segment}->add_route(
            method        => $method,
            path_segments => $path_segments,
            controller    => $controller,
        );
        return;
    }

    $self->children->{$segment} = JVRecipes::Router::Node->new(
        segment => $segment
    ) unless exists $self->children->{$segment};

    $self->children->{$segment}->add_route(
        method        => $method,
        path_segments => $path_segments,
        controller    => $controller,
    );
}

sub _add_handler {
    my $self       = shift;
    my $method     = shift;
    my $controller = shift;

    croak "Duplicate route for $method on " . $self->segment
        if exists $self->handlers->{$method};

    $self->handlers->{$method} = $controller;
}

sub find_route {
    my $self = shift;
    my %args = @_;

    my $method        = $args{method};
    my $path_segments = $args{path_segments};
    my $params        = $args{params} // {};

    unless (@$path_segments) {
        my $handler = $self->handlers->{$method} || $self->handlers->{"ANY"};
        return wantarray ? ($handler, $params) : $handler if $handler;

        return wantarray ? (undef, $params, scalar(keys %{$self->handlers})) : undef 
            if keys %{$self->handlers};
        
        return wantarray ? (undef, $params, 0) : undef;
    }

    my $segment   = shift @$path_segments;
    my @remaining = @$path_segments;

    if(exists $self->children->{$segment}) {
        my ($handler, $match_params, $has_methods) =
            $self->children->{$segment}->find_route(
                method => $method,
                path_segments => \@remaining,
                params => $params,
            );
        
        return wantarray ? ($handler, $match_params, $has_methods) : $handler if $handler;
        return wantarray ? (undef, $params, $has_methods) : undef if $has_methods;
    }

    for my $child_key (keys $self->children->%*) {
        my $child = $self->children->{$child_key};

        if($child_key =~ /^:/) {
            my %new_params = %$params;
            $new_params{$child->param_name} = $segment;

            my ($handler, $match_params, $has_methods) =
                $child->find_route(
                    method        => $method,
                    path_segments => \@remaining,
                    params        => \%new_params
                );
            
            return wantarray ? ($handler, $match_params, $has_methods) : $handler if $handler;
            return wantarray ? (undef, $params, $has_methods) : undef if $has_methods;
        }
    }

    return wantarray 
      ? ($self->wildcard->handlers->{$method} || $self->wildcard->handlers->{"ANY"}, $params, scalar keys $self->wildcard->handlers->%*)
      : $self->wildcard->handlers->{$method} || $self->wildcard->handlers->{"ANY"}
      if $self->wildcard;
    
    return wantarray ? (undef, $params, 0) : undef;
}

1;