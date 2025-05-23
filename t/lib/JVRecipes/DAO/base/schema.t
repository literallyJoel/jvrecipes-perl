use JVRecipes::Tests::Base;
use JVRecipes::DAO::Base;

use aliased "JVRecipes::Object::Database::Column" => "Column";
use aliased "JVRecipes::Object::Database::Table"  => "Table";
use aliased "JVRecipes::Object::Database::Schema" => "Schema";

use Test2::Mock;
use Try::Tiny;

{
    package TestDAO;

    use Mouse;
    extends "JVRecipes::DAO::Base";

    sub table_name {"users"}

}

my $mock = Test2::Mock->new(
    class => "JVRecipes::DAO::Base",
    override => {
        _get_schema => sub {
            my $schema = Schema->new(
                tables => [
                    Table->new(
                        name    => "users",
                        columns => [
                            Column->new({
                                name        => "id",
                                type        => "uuid",
                                primary_key => 1,
                                default     => "gen_random_uuid()",
                            }),
                            Column->new({
                                name        => "email",
                                type        => "varchar",
                                constraints => ["UNIQUE"],
                                nullable    => 1,
                            }),
                            Column->new({
                                name     => "name",
                                type     => "varchar",
                                nullable => 1,
                            }),
                            Column->new({
                                name    => "created_at",
                                type    => "timestamptz",
                                default => "CURRENT_TIMESTAMP",
                            }),
                            Column->new({
                                name    => "updated_at",
                                type    => "timestamptz",
                                default => "CURRENT_TIMESTAMP"
                            }),
                        ],
                    ),
                ]
            );

            return $schema;
        }
    }
);

my $dao = TestDAO->new;

subtest "Correctly decodes schema" => sub {
    no warnings "redefine";

    is($dao->table_name, "users", "Correct table name");
    is_deeply($dao->primary_keys, ["id"]);
    is_deeply($dao->columns, ["id", "email", "name", "created_at", "updated_at"], "Correct columns");

};

done_testing;