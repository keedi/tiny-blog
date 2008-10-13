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
        $c->stash->{title} = '꼬리표: ' . join(' & ', @tags);
        $c->stash->{tags}  = [ sort @tags ];
        $c->stash->{posts} = [ $c->model('DB')->get_posts_from_tags(@tags) ];
    }
    else {
        # 모든 태그 얻기
        $c->stash->{tags} = [ map { $_->name } $c->model('DB')->get_tags ];
    }
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
