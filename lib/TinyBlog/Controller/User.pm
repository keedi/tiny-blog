package TinyBlog::Controller::User;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched TinyBlog::Controller::User in User.');
}

=head2 login 

로그인 처리

=cut

sub login :Local {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{username} || q{};
    my $password = $c->request->params->{password} || q{};

    if ( $username && $password ) {
        if ( $c->authenticate({ username => $username,
                                password => $password}) ) {
            my $username = $c->user->username;
            $c->flash->{status_msg} = "로그인 완료: $username";
            $c->response->redirect( $c->uri_for('/') );
            return;
        }
        else {
            $c->stash->{error_msg} = '사용자 이름이나 비밀번호가 정확하지 않습니다.'
        }
    }
}

=head2 logout

로그아웃 처리

=cut

sub logout :Local {
    my ( $self, $c ) = @_;

    if ( $c->user_exists ) {
        my $username = $c->user->username;
        $c->logout;
        $c->flash->{status_msg} = "로그아웃 완료: $username";
        $c->response->redirect( $c->uri_for('/user/login') );
    }
    else {
        $c->stash->{error_msg} = "로그인 상태가 아니므로 로그아웃할 수 없습니다.";
    }
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
