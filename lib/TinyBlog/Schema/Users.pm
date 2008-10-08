package TinyBlog::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "username",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "password",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "nick",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "email",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "active",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-08 14:21:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z38mvvhek1eQ+GwXvajDkA


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    map_user_role => 'TinyBlog::Schema::UserRoles',
    'user_id',
    { cascading_delete => 1 },
);

__PACKAGE__->many_to_many(
    roles => 'map_user_role',
    'role',
);

1;
