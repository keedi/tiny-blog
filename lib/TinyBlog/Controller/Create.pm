package TinyBlog::Controller::Create;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::Create - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

새로운 글을 등록합니다.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('/user/check', [ 'create' ]);
    $c->detach('access_denied')
        unless $c->stash->{return};

    my $title    = $c->request->params->{title}    || q{};
    my $tag      = $c->request->params->{tags}     || q{};
    my $contents = $c->request->params->{contents} || q{};

    my @tags = map { s/^\s+//; s/\s+$//; $_ } split /,/, $tag;
    if ( $title && @tags && $contents ) {
        my $author = $c->user->username;

        my $post = $c->model('DB::Posts')->find_or_new({id => undef});
        $post->author  ($c->user->username);
        $post->title   ($title);
        $post->contents($contents);
        $post->update_or_insert;

        for my $tag_str ( @tags ) {
            my $tag = $c->model('DB::Tags')->find_or_new({name => $tag_str});
            $tag->update_or_insert;

            my $post_tag = $c->model('DB::PostTags')->find_or_new({
                post_id => $post->id,
                tag_id  => $tag->id,
            });
            $post_tag->update_or_insert;
        }

        $c->flash->{status_msg} = "'$title' 글을 등록했습니다.";
        $c->response->redirect( $c->uri_for('/id/'.$post->id) );
    }
}

=head2 access_denied

Catalyst::Plugin::Authorization::ACL 접근금지 예외 처리

=cut

sub access_denied :Private {
    my ( $self, $c ) = @_;

    $c->stash->{error_msg} = '권한이 없습니다!';
    $c->stash->{template} = 'recent/index.tt2';
    $c->forward('/recent/index');
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
