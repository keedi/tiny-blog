package TinyBlog::Schema::Posts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("posts");
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DBKu0ZhOjMQtmztG4WDSKQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    post_replies => 'TinyBlog::Schema::PostReplies',
    'post_id',
    { cascading_delete => 1, },
);

__PACKAGE__->many_to_many(
    replies => 'post_replies',
    'reply',
);

__PACKAGE__->has_many(
    post_tags => 'TinyBlog::Schema::PostTags',
    'post_id',
    { cascading_delete => 1, },
);

__PACKAGE__->many_to_many(
    tags => 'post_tags',
    'tag',
);

1;
