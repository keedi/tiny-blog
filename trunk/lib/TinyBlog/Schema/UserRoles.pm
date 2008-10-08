package TinyBlog::Schema::UserRoles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_roles");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "role_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("user_id", "role_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-08 14:21:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TXue8FV0pXwoKzpd5TOubA


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    user => 'TinyBlog::Schema::Users',
    'user_id',
);

__PACKAGE__->belongs_to(
    role => 'TinyBlog::Schema::Roles',
    'role_id',
);

1;
