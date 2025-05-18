use JVRecipes::Tests::Base;
use JVRecipes::Router::Base;

use JSON::MaybeXS qw(decode_json);

my $router          = JVRecipes::Router::Base->new;
my $prefixed_router = JVRecipes::Router::Base->new(prefix => "/test");

{
  package A::Test::Endpoint;

  use Mouse;
  with "JVRecipes::Role::Endpoint::Base";

  sub run {
    my $self = shift;

    $self->send_response(content => {message => "OK"});
  }
}

{
  package A::Test::Router;

  use Mouse;
  with "JVRecipes::Role::Router";

  sub BUILD {
    my $self = shift;

    for my $op (qw(get post patch delete put any)) {
      $self->$op("/$op", "A::Test::Endpoint");
    }
  }
}

subtest "Router Constructed" => sub {
  ok($router, "Router created");
  is($router->prefix, "", "Router created with empty prefix");

  ok($router, "Router created");
  is($prefixed_router->prefix, "/test", "Router created with provided prefix");
};

subtest "Routes correctly registered" => sub {
  for my $op (qw(get post delete put patch any)) {
    $router->$op("/$op", "A::Test::Endpoint");
    $prefixed_router->$op("/$op", "A::Test::Endpoint");
    ok($router->_routes->{children}->{$op}, "$op route registered (no prefix)");
    ok($prefixed_router->_routes->{children}->{test}->{children}->{$op}, "$op route registered (prefix)");
  }
};

subtest "Group routing" => sub {
  my $group_router = JVRecipes::Router::Base->new;
  $group_router->group("/api", "A::Test::Router");

  for my $op (qw(get post delete put patch any)) {
    ok(
      $group_router->_routes->{children}->{api}->{children}->{$op},
      "$op route registered via group routing"
    );
  }
};

subtest "valid route" => sub {
  $router->get("/handle_test", "A::Test::Endpoint");

  my $env = {
    "REQUEST_METHOD" => "GET",
    "PATH_INFO"      => "/handle_test",
  };

  my $response = $router->handle($env);
  ok($response, "Response received from handle method");
  is($response->[0], 200, "Status code is 200");

  my $content = decode_json($response->[2][0]);
  is($content->{message}, "OK", "Correct content returned");
};

subtest "Invalid Route" => sub {
  my $env = {
    "REQUEST_METHOD" => "GET",
    "PATH_INFO"      => "/nonexistent",
  };

  my $response = $router->handle($env);
  ok($response, "Response received from handle method (404)");
  is($response->[0], 404, "Status code is 404");
};

subtest "Invalid Method" => sub {
  $router->get("/method_test", "A::Test::Endpoint");

  my $env = {
    "REQUEST_METHOD" => "POST",
    "PATH_INFO"      => "/method_test",
  };

  my $response = $router->handle($env);
  ok($response, "Response received from handle method (405)");
  is($response->[0], 405, "Status code is 405");
};

done_testing;
