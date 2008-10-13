package TinyBlog::Controller::Feeds;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use XML::Feed;
use DateTime;
use Text::MultiMarkdown 'markdown';


=head1 NAME

TinyBlog::Controller::Feeds - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

기본으로 최근 글 피드를 출력한다.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('posts');
}

=head2 posts

최근 글 피드

=cut

sub posts :Local {
    my ( $self, $c, $feed_type ) = @_;

    $c->stash->{posts} = [ $c->model('DB')->get_recent_posts ];
}

=head2 comments

최근 답글 피드

=cut

sub comments :Local {
    my ( $self, $c, $feed_type ) = @_;

    $c->stash->{posts} = [ ];
}

=head2 tags

특정 태그의 최근 글 피드

=cut

sub tags :Local {
    my ( $self, $c, @tags ) = @_;

    $c->stash->{posts} = [ $c->model('DB')->get_posts_from_tags(@tags) ];
}

=head2 end

공통적으로 피드를 처리하는 부분

=cut

sub end :Private {
    my ( $self, $c ) = @_;

    my $feed = XML::Feed->new( $c->stash->{type} );
    $feed->title      ( $c->config->{title}       );
    $feed->description( $c->config->{description} );
    $feed->author     ( $c->config->{author}      );
    $feed->language   ( $c->config->{language}    );
    $feed->link       ( $c->uri_for('/')          );

    my @posts_rs = $c->stash->{posts} ? @{ $c->stash->{posts} } : ();
    for my $post ( @posts_rs ) {

        my $entry = XML::Feed::Entry->new( $c->stash->{type} );

        my $url = $c->uri_for('/id/'.$post->id);
        my $contents
            = "<p>"
            . "<strong>주의</strong>: ["
            . $post->title
            . "]의 가장 최근 판은 "
            . "<a href=$url>이곳</a>에서 확인할 수 있습니다."
            . "</p>"
            . markdown( $post->contents )
            ;

        $entry->title   ( $post->title  );
        $entry->content ( $contents     );
        $entry->author  ( $post->author );
        $entry->link    ( $url          );

        # FIXME $self->context 를 사용할 수 없다?
        my $timezone = $c->config->{timezone};
        $entry->issued  ( $self->datetime( $post->created_on, $timezone ) );
        $entry->modified( $self->datetime( $post->updated_on, $timezone ) );

        $feed->add_entry( $entry );
    }

    $c->response->content_type( 'application/xml' );
    $c->response->body( $feed->as_xml );
}

=head2 datetime

날짜 문자열을 이용해서 DateTime 객체 반환

=cut

sub datetime {
    my ( $self, $datetime, $timezone ) = @_;

    my ( $ymd,  $hms         ) = split / /, $datetime;
    my ( $year, $month, $day ) = split /-/, $ymd;
    my ( $hour, $min,   $sec ) = split /:/, $hms;

    my $dt = DateTime->new(
        year       => $year,
        month      => $month,
        day        => $day,
        hour       => $hour,
        minute     => $min,
        second     => $sec,
        time_zone  => $timezone
    );

    return $dt;
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
