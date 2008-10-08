package TinyBlog::Controller::Tags;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::Tags - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args {
    my ( $self, $c, @tags ) = @_;

    if ( @tags ) {
        # 특정 태그 검색
        my $tag = $c->model('DB::Tags')->find( { name => [ @tags ] } );

        $c->stash->{title} = '꼬리표: ' . join(' & ', @tags);
        $c->stash->{tags}  = [ @tags ];
        $c->stash->{posts} = [ $tag->posts ] if $tag;
    }
    else {
        # 모든 태그 얻기
        my $tag_rs = $c->model('DB::Tags')->search(
            undef,
            {
                order_by => 'name ASC',
            },
        );
        my @tags = map { $_->name } $tag_rs->all;
        $c->stash->{tags} = [ @tags ];
    }
}


=head1 AUTHOR

Mooninchul,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
