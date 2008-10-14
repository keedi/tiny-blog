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
my ( $action, $username, @argv ) = @ARGV;

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
elsif ( $action eq 'edit' ) {
    my $user = $schema->resultset('Users')->find( { username => $username } )
        or die "Cannot find [$username]";

    my $field = shift @argv;
    die usage() unless $field;

    my $old_value;
    if ( $field eq 'roles' ) {
        $old_value = join ', ', map { $_->role } $user->roles;
    }
    else {
        $old_value = eval "\$user->$field";
        if ( $@ ) {
            die "Getting $field failed: $@";
        }
    }

    printf "Old: %15s: %s\n", $field, $old_value;
    printf "New: %15s: ", $field;
    my $new_value = <STDIN>;
    chomp $new_value;

    print "Check...\n";
    printf "Old: %15s: %s\n", $field, $old_value;
    printf "New: %15s: %s\n", $field, $new_value;

    print "Edit $field field of $username? (yes/no): ";
    my $confirm = <STDIN>;
    chomp $confirm;

    if ( $confirm =~ /^yes$/i ) {

        if ( $field eq 'roles' ) {
            my @role_names = map { s/^\s+//; s/\s+$//; $_ } split /,/, $new_value;
            for my $role_name ( @role_names ) {

                my $role = $schema->resultset('Roles')->find({ role => $role_name });
                next unless $role;

                my $user_role = $schema->resultset('UserRoles')->find_or_create( {
                    user_id => $user->id,
                    role_id => $role->id,
                } );
                $user_role->update;
            }
        }
        else {
            eval "\$user->$field($new_value)";
            if ( $@ ) {
                die "Editing $field field of $username failed: $@";
            }
        }
        $user->update;
    }
    else {
        die "Canceled [$action] process!\n";
    }
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
Usage: $0 <action> <username> [ <arg1> ... ]

action: view, add, del, edit
END_USAGE
}
