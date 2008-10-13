#!/usr/bin/perl 

use strict;
use warnings;

use FindBin qw($Bin);
use Path::Class;
use lib dir($Bin, '..', 'lib')->stringify;

use Config::General qw/ParseConfig/;
use Digest::SHA;
use TinyBlog::Schema;

#
# 명령행 인자 처리
#
die usage()
    unless @ARGV >= 2;
my ( $action, $username ) = @ARGV;

#
# DB 접속
#
my $config       = { ParseConfig(file($Bin, '..', 'tinyblog.conf')) };
my $HOME         = dir($Bin, '..');
my $connect_info = $config->{'Model::DB'}->{connect_info};

my $dsn = ref($connect_info) eq 'ARRAY' ? $connect_info->[0] : $connect_info;
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

    printf "%15s: %s\n", $_, $param_of{$_}
        for qw/ username nick email active roles /;
}
elsif ( $action eq 'add' ) {
    my $user = $schema->resultset('Users')->find( { username => $username } )
        and die "Already exists [$username]";

    my %param_of;
    $param_of{username} = $username;
    for my $key ( qw/ password password_again nick email active roles / ) {
        printf "%15s: ", $key;
        my $value = <STDIN>;
        chomp $value;
        $param_of{$key} = $value;

        die "Canceled [$action] process!\n"
            if ($key eq 'password_again' && $param_of{password} ne $value);
    }
    $param_of{active}   = $param_of{active} == 1 ? 1 : 0;
    $param_of{password} = Digest::SHA::sha1_hex($param_of{password});

    print "Check the information...\n";
    printf "%15s: %s\n", $_, $param_of{$_}
        for qw/ username nick email active roles /;
    print "Add this user? (yes/no): ";
    my $confirm = <STDIN>;
    chomp $confirm;

    if ( $confirm =~ /^yes$/i ) {

        my $user = $schema->resultset('Users')->create( {
            username => $param_of{username},
            password => $param_of{password},
            nick     => $param_of{nick},
            email    => $param_of{email},
            active   => $param_of{active},
        } );

        my @role_names = map { s/^\s+//; s/\s+$//; $_ } split /,/, $param_of{roles};
        for my $role_name ( @role_names ) {

            my $role = $schema->resultset('Roles')->find({ role => $role_name });
            next unless $role;

            my $user_role = $schema->resultset('UserRoles')->create( {
                user_id => $user->id,
                role_id => $role->id,
            } );
        }
    }
    else {
        die "Canceled [$action] process!\n";
    }
}
elsif ( $action eq 'del' ) {
    my $user = $schema->resultset('Users')->find( { username => $username } )
        or die "Cannot find [$username]";

    my %param_of = (
        username => $user->username,
        nick     => $user->nick,
        email    => $user->email,
        active   => $user->active,
        roles    => join(', ', map { $_->role } $user->roles),
    );

    print "Check the information...\n";
    printf "%15s: %s\n", $_, $param_of{$_}
        for qw/ username nick email active roles /;
    print "Delete this user? (yes/no): ";

    my $confirm = <STDIN>;
    chomp $confirm;
    if ( $confirm =~ /^yes$/i ) {
        $user->delete;
    }
    else {
        die "Canceled [$action] process!\n";
    }
}
else {
    die usage();
}

sub usage {
    return <<"END_USAGE";
Usage: $0 <action> <username>

action: view, add, del
END_USAGE
}
