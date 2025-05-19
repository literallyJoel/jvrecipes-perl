use JVRecipes::Tests::Base;

use Carp;
use JVRecipes::Router::Node;
use Try::Tiny;

subtest "Constructor and default attributes" => sub {
  my $node = JVRecipes::Router::Node->new();

  ok($node, "Node created");
  is($node->segment, "", "Correct default segment");
  is_deeply($node->children, {}, "Correct default children");
  is($node->param_name, undef, "Correct default param_name");
  is_deeply($node->handlers, {}, "Correct default handlers");
  is($node->wildcard, undef, "Correct default wildcard");

  my $node2 = JVRecipes::Router::Node->new(segment => "test", param_name => "id");
  is($node2->segment, "test", "Segment correctly set");
  is($node2->param_name, "id", "param_name correctly set");
};

subtest "Add Basic Routes" => sub {
  my $node = JVRecipes::Router::Node->new;

  for my $op (qw(POST GET PATCH PUT DELETE ANY)) {
    $node->add_route(method => $op, path_segments => [], controller => $op."Controller");
    is($node->handlers->{$op}, $op."Controller", "Handler correctly added for $op");

  }
};

subtest "Add Segment Routes" => sub {
    my $node = JVRecipes::Router::Node->new;

    for my $op (qw(POST GET PATCH PUT DELETE ANY)) {
        $node->add_route(method => $op, path_segments => ["seg"], controller => $op."Controller");
        is($node->children->{seg}->handlers->{$op}, $op."Controller", "Child handler correctly added for $op");
    }
};

subtest "Add param routes" => sub {
    my $node = JVRecipes::Router::Node->new;

    for my $op (qw(POST GET PATCH PUT DELETE ANY)) {
        $node->add_route(method => $op, path_segments => [":param"], controller => $op."Controller");
        is($node->children->{":param"}->handlers->{$op}, $op."Controller", "Param handler correctly added for $op");
    }

    is($node->children->{":param"}->param_name, "param", "Param name set correctly");
};

subtest "Add wildcard routes" => sub {
  my $node = JVRecipes::Router::Node->new;

  for my $op (qw(POST GET PATCH PUT DELETE ANY)) {
    $node->add_route(method => $op, path_segments => ["*"], controller => $op."Controller");
    is($node->wildcard->handlers->{$op}, $op."Controller", "Handler correctly added to wildcard for $op");
  }
};

subtest "Find basic routes" => sub {
  my $node = JVRecipes::Router::Node->new;

  my ($controller) = $node->find_route(method => "GET", path_segments => []);
  ok(!$controller, "undef returned on not found");

  for my $op (qw(POST GET PATCH PUT DELETE)) {
    $node->add_route(method => $op, path_segments => [], controller => $op."Controller");
    ($controller) = $node->find_route(method => $op, path_segments => []);
    is($controller, $op."Controller", "Correct controller found for $op");
  }

  my $node2 = JVRecipes::Router::Node->new;
  $node2->add_route(method => "GET", path_segments => ["child"], controller => "MyController");
  my ($controller3) = $node2->find_route(method => "GET", path_segments => ["child"]);
  is($controller3, "MyController", "find_route returns controller for child");
};

subtest "Find child routes" => sub {
    my $node = JVRecipes::Router::Node->new;

    my ($controller) = $node->find_route(method => "GET", path_segments => ["seg"]);
    ok(!$controller, "undef returned on not found");

    for my $op (qw(POST GET PATCH PUT DELETE)) {
        $node->add_route(method => $op, path_segments => ["seg"], controller => $op."Controller");
        ($controller) = $node->find_route(method => $op, path_segments => ["seg"]);
        is($controller, $op."Controller", "Correct controller found for $op");
    }
};

subtest "Find child routes (multiple segments)" => sub {
    my $node = JVRecipes::Router::Node->new;

    my ($controller) = $node->find_route(method => "GET", path_segments => ["seg", "ment"]);
    ok(!$controller, "undef returned on not found");

    for my $op (qw(POST GET PATCH PUT DELETE)) {
        $node->add_route(method => $op, path_segments => ["seg", "ment"], controller => $op."Controller");
        ($controller) = $node->find_route(method => $op, path_segments => ["seg", "ment"]);
        is($controller, $op."Controller", "Correct controller found for $op");
    }
};

subtest "Find ANY route" => sub {
  my $node = JVRecipes::Router::Node->new;
  $node->add_route(method => "ANY", path_segments => [], controller => "Controller");

  for my $op (qw(POST GET PATCH PUT DELETE)) {
    my ($controller) = $node->find_route(method => $op, path_segments => []);
    is($controller, "Controller", "$op correctly routed for ANY route");
  }
};

subtest "Find parameter routes" => sub {
    my $node = JVRecipes::Router::Node->new;

    for my $op (qw(POST GET PATCH PUT DELETE)) {
        $node->add_route(method => $op, path_segments => [":param1", ":param2"], controller => $op."Controller");
        my ($controller, $params) = $node->find_route(method => $op, path_segments => ["returned", "value"]);

        is($controller, $op."Controller", "Correct controller found for $op");
        is($params->{param1}, "returned", "Correct first parameter returned for $op");
        is($params->{param2}, "value", "Correct second param returned for $op");
    }
};

subtest "Wildcard Validation" => sub {

    my $node = JVRecipes::Router::Node->new;

    my $died = 1;

    try {
        $node->add_route(method => "GET", path_segments => ["*", "seg"], controller => "Controller");
        $died = 0;
    };
    ok($died, "Dies on invalid wildcard");

    try {
        $node->add_route(method => "GET", path_segments => ["seg", "*"], controller => "Controller");
        $died = 0;
    };
    ok(!$died, "Does not die on valid wildcard");
};

subtest "Duplicate Validation" => sub {
  my $node = JVRecipes::Router::Node->new();

  my $died = 1;

  try {
    $node->add_route(method => "GET", path_segments => [], controller => "Controller");
    $died = 0;
  };
  ok(!$died, "Doesn't die if not duplicate");

  $died = 1;

  try {
    $node->add_route(method => "GET", path_segments => [], controller => "Controller");
    $died = 0;
  };
  ok($died, "Dies if duplicate");
};

done_testing;
