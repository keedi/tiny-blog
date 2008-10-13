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

/feeds/rss 로 포워딩

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('atom');
}

=head2 atom

atom 형식의 피드

=cut

sub atom :Local {
    my ( $self, $c ) = @_;

    $c->stash->{type} = 'Atom';
}

=head2 rss

rss 형식의 피드

=cut

sub rss :Local {
    my ( $self, $c ) = @_;

    $c->stash->{type} = 'RSS';
}

=head2 end

공통적으로 피드를 처리하는 부분

=cut

sub end :Private {
    my ( $self, $c ) = @_;

    my @posts_rs = $c->model('DB')->get_recent_posts;

    my $feed = XML::Feed->new( $c->stash->{type} );
    $feed->title      ( $c->config->{title}       );
    $feed->description( $c->config->{description} );
    $feed->author     ( $c->config->{author}      );
    $feed->language   ( $c->config->{language}    );
    $feed->link       ( $c->uri_for('/')          );

    for my $post ( @posts_rs ) {

        my $entry = XML::Feed::Entry->new( $c->stash->{type} );
        $entry->title   ( $post->title                  );
        $entry->content ( markdown($post->contents)     );
        $entry->author  ( $post->author                 );
        $entry->link    ( $c->uri_for('/id/'.$post->id) );

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
