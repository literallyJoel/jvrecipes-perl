use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::MockModule;
use JVRecipes::Router::Base;

subtest 'Constructor new() behavior' => sub {
    my $router = JVRecipes::Router::Base->new({ default => 'home' });
    ok($router, 'new returns a router object');
    isa_ok($router, 'JVRecipes::Router::Base', 'object is correct class');

    throws_ok { JVRecipes::Router::Base->new() } qr/Configuration required/,
      'dies when config is missing';
};

subtest 'route() method' => sub {
    my $router = JVRecipes::Router::Base->new({ default => 'home' });
    is($router->route('/about'), 'about_page', 'correctly routes /about');
    is($router->route('/'),       'home_page',  'uses default for "/"');
    throws_ok { $router->route('///') } qr/Invalid path/,
      'dies on malformed path';
};

subtest 'parse_path() behavior' => sub {
    my $router = JVRecipes::Router::Base->new({ default => 'home' });
    my $segments = $router->parse_path('/one/two');
    is_deeply($segments, ['one','two'], 'splits path correctly');

    throws_ok { $router->parse_path('no_slash') } qr/Path must start with \//,
      'dies on missing leading slash';
    throws_ok { $router->parse_path(undef) } qr/Undefined path/,
      'dies on undef input';
};

subtest 'route() delegates to dispatcher' => sub {
    my $mock = Test::MockModule->new('JVRecipes::Router::Dispatcher');
    $mock->mock('dispatch', sub { 'mocked_result' });

    my $router = JVRecipes::Router::Base->new({ default => 'home' });
    is($router->route('/foo'), 'mocked_result', 'delegates to Dispatcher::dispatch');

    $mock->unmock('dispatch');
};

done_testing;