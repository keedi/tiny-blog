package TinyBlog::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'TinyBlog::Schema',
    connect_info => [
        'dbi:SQLite:tinyblog.db',
        
    ],
);

use FindBin qw($Bin);
use Path::Class;
use lib dir($Bin, '..', 'lib')->stringify;

use Config::General 'ParseConfig';
my $config = { ParseConfig(file($Bin, '..', 'tinyblog.conf')) };

=head1 NAME

TinyBlog::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<TinyBlog>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<TinyBlog::Schema>

=head1 METHODS

=cut


=head2 get_recent_posts

=cut

sub get_recent_posts {
    my $self = shift;

    my $posts_rs = $self->resultset('Posts')->search(
        undef,
        {
            page     => 1,
            rows     => $config->{recent},
            order_by => 'created_on DESC',
        },
    );

    return unless $posts_rs;
    return $posts_rs->all;
}

=head2 get_posts_from_tags

=cut

sub get_posts_from_tags {
    my ( $self, @tags ) = @_;

    return unless @tags;

    # FIXME
    # resultset에 post가 중복해서 들어간다.
    # 이것을 해결할 수 있는 방법을 찾는다.
    my $posts_rs = $self->resultset('Posts')->search(
        {
            'tag.name' => [ @tags ],
        },
        {
            join => { 'post_tags' => 'tag' },
        },
    );

    return unless $posts_rs;
    my %uniq_posts_rs = map { $_->id => [ $_->created_on, $_ ] } $posts_rs->all;
    return(
        map {
            $_->[1]
        } sort {
            $b->[0] cmp $a->[0]     # 최근 글이 앞으로 오도록
        } values %uniq_posts_rs
    );  # FIXME 중복 제거
}

=head2 get_tags

=cut

sub get_tags {
    my ( $self, @keywords ) = @_;

    my $tags_rs;
    if ( @keywords ) {
        $tags_rs = $self->resultset('Tags')->search(
            {
                'name' => [ @keywords ],
            },
            {
                order_by => 'name ASC',
            },
        );
    }
    else {
        $tags_rs = $self->resultset('Tags')->search(
            undef,
            {
                order_by => 'name ASC',
            },
        );
    }

    return unless $tags_rs;
    return $tags_rs->all;
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
