package TinyBlog::Schema::PostReplies;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("post_replies");
__PACKAGE__->add_columns(
  "post_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "reply_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("post_id", "reply_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-08 14:21:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WTIFeTK/nUJSoi+qZS5cng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
