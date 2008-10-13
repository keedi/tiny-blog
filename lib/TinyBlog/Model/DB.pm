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


=head2 hello

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

    return $posts_rs->all;
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
