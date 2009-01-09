package TinyBlog::DBIC::AutoStoreDateTime;
use strict;
use warnings;
use base 'DBIx::Class';

use DateTime;
use TinyBlog;
my $config = TinyBlog->config;

sub insert {
    my $self = shift;

    my $dt       = DateTime->now( time_zone => $config->{timezone} );
    my $date_str = $dt->ymd . ' ' . $dt->hms;

    $self->created_on( $date_str )
        if $self->result_source->has_column('created_on');
    $self->updated_on( $date_str )
        if $self->result_source->has_column('updated_on');
    $self->published_on( $date_str )
        if $self->result_source->has_column('published_on');
    $self->next::method(@_);
}

sub update {
    my $self = shift;

    my $dt = DateTime->now( time_zone => $config->{timezone} );
    my $date_str = $dt->ymd . ' ' . $dt->hms;

    $self->updated_on( $date_str )
        if $self->result_source->has_column('updated_on');

    $self->next::method(@_);
}

1;
