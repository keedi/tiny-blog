#!/usr/bin/perl 

use strict;
use warnings;

use FindBin qw($Bin);
use Path::Class;
use lib dir($Bin, '..', 'lib')->stringify;

use Config::General qw/ParseConfig/;
use TinyBlog::Schema;

#
# 명령행 인자 처리
#
die "Usage: $0 <action> <username> [<param1> <param2> ... ]"
    unless @ARGV >= 2;
my ( $action, $username ) = @ARGV;

#
# DB 접속
#
my $config = { ParseConfig(file($Bin, '..', 'tinyblog.conf')) };
my $HOME   = dir($Bin, '..');
my $dsn    = $config->{'Model::DB'}->{connect_info};
$dsn =~ s/__HOME__/$HOME/;
my $schema = TinyBlog::Schema->connect($dsn)
    or die "Failed to connect to database at $dsn";

#
# view, add, del 동작 처리
#
if ( $action eq 'view' ) {
    my $user = $schema->resultset('Users')->find( { username => $username } )
        or die "Cannot find [$username]";

    my %param_of = (
        username => $user->username,
        nick     => $user->nick,
        email    => $user->email,
        active   => $user->active,
        roles    => join(', ', map { $_->role } $user->roles),
    );

    printf "%10s: %s\n", $_, $param_of{$_}
        for qw/ username nick email active roles /;
}
elsif ( $action eq 'add' ) {
    my $user = $schema->resultset('Users')->find( { username => $username } )
        and die "Already exists [$username]";

    my %param_of;
    $param_of{username} = $username;
    for my $key ( qw/ nick email active roles / ) {
        printf "%10s: ", $key;
        my $value = <STDIN>;
        chomp $value;
        $param_of{$key} = $value;
    }

    print "let's add... [TODO]\n";
}
elsif ( $action eq 'del' ) {
    my $user = $schema->resultset('Users')->find( { username => $username } )
        or die "Cannot find [$username]";
    print "let's delete... [TODO]\n";
}
else {
    die
        "Usage: $0 <action> <username>\n",
        "    action: view, add, del\n";
}

