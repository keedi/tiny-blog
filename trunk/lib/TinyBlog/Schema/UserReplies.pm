package TinyBlog::Schema::UserReplies;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_replies");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "reply_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("user_id", "reply_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-09 03:45:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LLS3m/zssGJYKYseidl5KQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
    user => 'TinyBlog::Schema::Users',
    'user_id',
);

__PACKAGE__->belongs_to(
    reply => 'TinyBlog::Schema::Replies',
    'reply_id',
);

1;
