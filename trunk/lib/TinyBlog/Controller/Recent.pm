package TinyBlog::Controller::Recent;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::Recent - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

최근 글을 보여줍니다.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $posts_rs = $c->model('DB::Posts')->search(
        undef,
        {
            page     => 1,
            rows     => $c->config->{recent},
            order_by => 'created_on DESC',
        },
    );

    $c->stash->{posts} = [ $posts_rs->all ];
}


=head1 AUTHOR

Mooninchul,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
