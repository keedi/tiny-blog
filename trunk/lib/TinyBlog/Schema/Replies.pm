package TinyBlog::Schema::Replies;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto +TinyBlog::DBIC::AutoStoreDateTime Core/);
__PACKAGE__->table("replies");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "author",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "created_on",
  { data_type => "DATETIME", is_nullable => 0, size => undef },
  "updated_on",
  { data_type => "DATETIME", is_nullable => 0, size => undef },
  "title",
  { data_type => "TEXT", is_nullable => 0, size => undef },
  "contents",
  { data_type => "LONGTEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-08 14:21:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bztEa+kK/hj0WdzG1WsBVw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    post_replies => 'TinyBlog::Schema::PostReplies',
    'reply_id',
);

__PACKAGE__->many_to_many(
    posts => 'post_replies',
    'post',
);

1;
