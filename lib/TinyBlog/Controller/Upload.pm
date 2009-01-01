package TinyBlog::Controller::Upload;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::Upload - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

파일을 업로드 합니다.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->detach('access_denied')
        unless $c->forward('/user/check', [ 'upload' ]);

    #$c->response->body('Matched TinyBlog::Controller::Upload in Upload.');
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
