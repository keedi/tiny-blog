package TinyBlog::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'TinyBlog::Schema',
    connect_info => [
        'dbi:SQLite:tinyblog.db',
        
    ],
);

=head1 NAME

TinyBlog::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<TinyBlog>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<TinyBlog::Schema>

=head1 AUTHOR

Mooninchul,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
