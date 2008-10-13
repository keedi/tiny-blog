package TinyBlog::View::TT;

use strict;
use base 'Catalyst::View::TT';
use Text::MultiMarkdown;

{
    no warnings qw/redefine/;
    sub Text::MultiMarkdown::_GenerateHeader {
        my ($self, $level, $id) = @_;

        my $start_level = $self->{params}->{start_level};
        $start_level ||= 1;
        $level += ($start_level - 1);

        return "<h$level>"  .  $self->_RunSpanGamut($id)  .  "</h$level>\n\n";
    }
}

my $m = Text::MultiMarkdown->new(
    tab_width     => 2,
    use_wikilinks => 0,
    start_level   => 3,
);

__PACKAGE__->config({
    INCLUDE_PATH => [
        TinyBlog->path_to( 'root', 'src' ),
        TinyBlog->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    TEMPLATE_EXTENSION => '.tt2',
    FILTERS      => {
        'markdown' => sub {
            my $text = shift;
            $text = $m->markdown($text);
            return $text;
        },
    },
});

=head1 NAME

TinyBlog::View::TT - Catalyst TTSite View

=head1 SYNOPSIS

See L<TinyBlog>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

