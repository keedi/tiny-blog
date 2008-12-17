package TinyBlog::Schema::Tags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("tags");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "name",
  { data_type => "TEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-08 14:21:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GwV5D4MH+Sbr9kBq3zAYVQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many(
    post_tags => 'TinyBlog::Schema::PostTags',
    'tag_id',
    { cascading_delete => 1, },
);

__PACKAGE__->many_to_many(
    posts => 'post_tags',
    'post',
    { order_by => 'updated_on DESC', },
);

1;
