package TinyBlog::Controller::Upload;

use strict;
use warnings;
use File::Path;
use File::Basename;
use parent 'Catalyst::Controller';

=head1 NAME

TinyBlog::Controller::Upload - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

파일을 업로드 합니다.

=cut

sub index :Path :Args {
    my ( $self, $c, @path ) = @_;

    $c->detach('access_denied')
        unless $c->forward('/user/check', [ 'upload' ]);

    $c->stash->{show_upload} = 0;

    # check temp directory for upload
    mkpath $c->config->{uploadtmp} unless -e $c->config->{uploadtmp};
    if (!-d $c->config->{uploadtmp}) {
        $c->stash->{error_msg} = "업로드 공간을 찾을 수 없습니다.";
        return;
    }

    # check user directory for copy file from temp directory
    my $userdir = $c->config->{userdir}.'/'.$c->user->username;
    mkpath $userdir unless -e $userdir;
    if (!-d $userdir) {
        $c->stash->{error_msg} = "사용자 디렉터리를 찾을 수 없습니다.";
        return;
    }

    my $upload_dir;
    my $dest_dir;
    if (@path) {
        $upload_dir = join '/', @path;
        $dest_dir   = "$userdir/$upload_dir";

        $c->stash->{title}   = "파일 업로드: $upload_dir";
    }
    else {
        $upload_dir = q{};
        $dest_dir   = $userdir;
    }
    $c->stash->{upload_dir} = $upload_dir;

    # check user specified directory
    mkpath $dest_dir unless -e $dest_dir;
    if (!-d $dest_dir) {
        $c->stash->{error_msg} = "[$upload_dir] 디렉터리를 찾을 수 없습니다.";
        return;
    }

    if ( $c->request->params->{mkdir} ) {
        my $mkdir = $c->request->params->{mkdir};
        $mkdir =~ s/[`~!@#\$%^&*()=+\[{\]}\\|;:'",<>\/?]+/_/g;
        $mkdir =~ s/\s+/_/g;
        $mkdir =~ s/_+/_/g;

        my $mkdir_path = "$dest_dir/$mkdir";
        mkpath $mkdir_path unless -e $mkdir_path;
        if (!-d $mkdir_path) {
            $c->stash->{error_msg} = "[$mkdir] 디렉터리를 만들 수 없습니다.";
        }
        else {
            $c->stash->{status_msg} = "[$mkdir] 디렉터리를 만들었습니다.";
        }
    }

    if ( my $upload = $c->request->upload('mkfile') ) {

        my $upload_basename = basename( $upload->filename );
        $upload_basename =~ s/[`~!@#\$%^&*()=+\[{\]}\\|;:'",<>\/?]+/_/g;
        $upload_basename =~ s/\s+/_/g;
        $upload_basename =~ s/_+/_/g;

        my $upload_path = $upload_dir ? "$upload_dir/$upload_basename" : $upload_basename;
        my $dest_path   = "$dest_dir/$upload_basename";

        if (!-e $dest_path) {
            $upload->copy_to($dest_path);
            $c->stash->{status_msg} = "[$upload_path] 업로드 완료";
        }
        else {
            $c->stash->{error_msg} = "[$upload_path] 파일이 이미 존재합니다.";
        }
    }

    # for directory listing
    if (opendir my $dh, $dest_dir) {
        my @nodes = sort grep !/^\.{1,2}$/, readdir $dh;
        my @files;
        my @dirs;
        for my $node ( @nodes ) {
            my $path = "$dest_dir/$node";
            if (-d $path) {
                push @dirs, { name => $node };
            }
            else {
                push @files, { name => $node, size => -s $path };
            }
        }
        $c->stash->{nodes} = \@nodes;
        $c->stash->{files} = \@files;
        $c->stash->{dirs}  = \@dirs;
    }
    else {
        $c->stash->{error_msg} = "[$upload_dir] 디렉터리를 열람할 수 없습니다.";
        return;
    }

    $c->stash->{show_upload} = 1;
}

=head2 access_denied

Catalyst::Plugin::Authorization::ACL 접근금지 예외 처리

=cut

sub access_denied :Private {
    my ( $self, $c ) = @_;

    $c->stash->{error_msg} = '권한이 없습니다!';
    $c->stash->{template} = 'recent/index.tt2';
    $c->forward('/recent/index');
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
