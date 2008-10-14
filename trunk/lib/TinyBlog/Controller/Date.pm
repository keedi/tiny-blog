package TinyBlog::Controller::Date;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::Date - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

날짜별 저장소 출력

=cut

sub index :Path :Args {
    my ( $self, $c, $year, $month ) = @_;

    if ( $year && !$month ) {
        $c->stash->{date} = {
            year  => $year,
            str   => sprintf("%04d년", $year),
        };
        $c->stash->{posts}
            = [ $c->model('DB')->get_posts_from_date( $year )  ];
    }
    elsif ( $year && 1 <= $month && $month <= 12 ) {
        $c->stash->{date} = {
            year  => $year,
            month => $month,
            str   => sprintf("%04d년 %02d월", $year, $month),
        };
        $c->stash->{posts}
            = [ $c->model('DB')->get_posts_from_date( $year, $month ) ];
    }
    else {
        $c->stash->{posts} = [];
        $c->stash->{error_msg} = '올바르지 않은 날짜 표현입니다.';
        return;
    }

    $c->stash->{title} = '저장소: ' . $c->{stash}->{date}->{str};
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
