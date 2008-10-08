package TinyBlog::Schema::PostTags;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("post_tags");
__PACKAGE__->add_columns(
  "post_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
  "tag_id",
  { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("post_id", "tag_id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-10-08 14:21:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j9xt05xAsRYZzvJ3KGiJ5Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
