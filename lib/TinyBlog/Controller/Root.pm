package TinyBlog::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

TinyBlog::Controller::Root - Root Controller for TinyBlog

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

/recent 페이지를 이용해서 첫화면을 표시

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('/recent/index');
    $c->stash->{title}    = $c->config->{description};
    $c->stash->{template} = 'recent/index.tt2';
}

=head2 default

404 not found 에러 페이지 출력

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->status(404);
    $c->stash->{error_msg} = '404 Page not found';
    $c->stash->{template}  = 'not_found.tt2';
}

=head2 end

Attempt to render a view, if needed.
폼 자동 채움

=cut 

sub end :Private {
    my ( $self, $c ) = @_;
    $c->forward('render');
    $c->fillform;
}

=head2 render

뷰를 자동으로 처리

=cut 

sub render : ActionClass('RenderView') {}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
