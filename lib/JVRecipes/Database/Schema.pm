package JVRecipes::Database::Schema;

use Mouse;
use Mouse::Util::TypeConstraints;
with "JVRecipes::Role::Database::Connector";

use aliased "JVRecipes::Object::Database::Column" => "Column";
use aliased "JVRecipes::Object::Database::Table"  => "Table";
use aliased "JVRecipes::Object::Database::Schema" => "Schema";

use Try::Tiny;

has schema => ( is => "ro", isa => "JVRecipes::Object::Database::Schema", lazy_build => 1);

sub generate {
    my $self = shift;

    my $query = $self->schema->query;

    return "Query is undefined" unless $query;

    try {
        $self->dbh->do($query);
    } catch {
        return $_;
    }

    return 0;
}

sub _build_schema {
    return Schema->new(
        tables => [
            Table->new({
                name    => "users",
                columns => [
                    Column->new({
                        name        => "id",
                        type        => "uuid",
                        constraints => ["PRIMARY KEY"],
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
            }),
            Table->new({
                name    => "auth_identities",
                columns => [
                    Column->new({
                        name        => "id",
                        type        => "uuid",
                        constraints => ["PRIMARY KEY"],
                        default     => "gen_random_uuid()",
                    }),
                    Column->new({
                        name        => "user_id",
                        type        => "uuid",
                        constraints => ["REFERENCES users(id) ON DELETE CASCADE"],
                    }),
                    Column->new({
                        name        => "provider",
                        type        => "varchar",
                        constraints => ["NOT NULL"],
                    }),
                    Column->new({
                        name        => "provider_id",
                        type        => "varchar",
                        constraints => ["NOT NULL"],
                    }),
                    Column->new({
                        name        => "created_at",
                        type        => "timestamptz",
                        constraints => ["NOT NULL"],
                        default     => "CURRENT_TIMESTAMP",
                    }),
                    Column->new({
                        name    => "updated_at",
                        type    => "timestamptz",
                        default => "CURRENT_TIMESTAMP",
                    }),
                ],
                constraints => [
                    "UNIQUE (provider, provider_id)",
                ],
            }),
            Table->new({
                name    => "password_hashes",
                columns => [
                    Column->new({
                        name        => "id",
                        type        => "uuid",
                        constraints => ["PRIMARY KEY"],
                        default     => "gen_random_uuid()",
                    }),
                    Column->new({
                        name        => "auth_identity_id",
                        type        => "uuid",
                        constraints => [
                            "REFERENCES auth_identities(id) ON DELETE CASCADE"
                        ],
                    }),
                    Column->new({
                        name        => "hash",
                        type        => "varchar",
                        constraints => ["NOT NULL"],
                    }),
                    Column->new({
                        name    => "created_at",
                        type    => "timestamptz",
                        default => "CURRENT_TIMESTAMP",
                    }),
                    Column->new({
                        name    => "updated_at",
                        type    => "timestamptz",
                        default => "CURRENT_TIMESTAMP",
                    }),
                ],
            }),
        ]
    );
}

1;
