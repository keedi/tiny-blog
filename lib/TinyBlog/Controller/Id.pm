package TinyBlog::Controller::Id;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Text::MultiMarkdown;
my $m = Text::MultiMarkdown->new(
    tab_width     => 2,
    use_wikilinks => 0,
    start_level   => 3,
);


=head1 NAME

TinyBlog::Controller::Id - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

글 식별자를 이용해서 해당 글을 표시
글 식별자가 존재하지 않으면 404 not found 표시

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $id ) = @_;

    my $post = $c->model('DB::Posts')->find( { id => $id } )
        or $c->detach('/default');
    # 템플릿에서 META를 처리할 수 없으므로 title 설정
    $c->stash->{title} = $post->title;
    $c->stash->{posts} = [ $post ];
}

=head2 id_view

id_view -> id_* 체인 액션
/id/*/... 처리

=cut

sub id_view :PathPart('id') :Chained('/') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $post = $c->model('DB::Posts')->find( { id => $id } )
        or $c->detach('/default');

    $c->stash->{post} = $post;
    $c->stash->{id}   = $id;
}

=head2 id_print

/id/*/print 체인액션 처리

=cut

sub id_print :PathPart('print') :Chained('id_view') :Args(0) {
    my ( $self, $c ) = @_;

    my $post = $c->stash->{post};
    my $id   = $c->stash->{id};

    $c->response->body(<<"END_PRINT"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
  <title>[@{[$c->config->{title}]}] @{[$post->title]}</title>
</head>

<style type="text/css" media="screen">
code, pre {
    font: 12px Monospace, Fixed;
}

pre {
    background-color: #f9f9f9;
    color: #110000;
    margin: 0 0 1.5em;
    border: 1px solid silver;
    padding: 2px 4px;
    overflow: auto;
    width: auto;
}
</style>

<body>
  <div id="page">

    <div id="header" style="float:right">
      <h1 class="title">@{[$c->config->{title}]}</h1>
      <div class="description">@{[$c->config->{description}]}</div>
    </div>

    <hr />

    <div id="content" style="line-height: 1.6em">

      <div class="post">
        <h2>@{[$post->title]}</h2>

        <div class="post_content">
          @{[ $m->markdown($post->contents) ]}
        </div>

        <hr />

        <div class="meta">
          <div class="tags">
            <p> 꼬리표: 
              @{[ join(', ', map { '<a href="'.$c->uri_for('/tags/').$_->name.'">'.$_->name.'</a>' } $post->tags) ]}
            </p>
          </div>
          <p>
            글쓴이: @{[$post->user_post->user->username]},
            작성: @{[$post->created_on]},
            출판: @{[$post->published_on]},
            갱신: @{[$post->updated_on]}
          </p>
        </div> <!-- end meta    -->
      </div>   <!-- end post    -->

    </div>     <!-- end content -->
  </div>       <!-- end page    -->

 </body>
</html>
END_PRINT
    );
}

=head2 id_edit

/id/*/edit 체인액션 처리

=cut

sub id_edit :PathPart('edit') :Chained('id_view') :Args(0) {
    my ( $self, $c ) = @_;

    $c->detach('access_denied')
        unless $c->forward('/user/check', [ 'edit' ]);

    my $post = $c->stash->{post};
    my $id   = $c->stash->{id};

    my $title    = $c->request->params->{title}    || q{};
    my $tag      = $c->request->params->{tags}     || q{};
    my $contents = $c->request->params->{contents} || q{};

    my @tags = map { s/^\s+//; s/\s+$//; $_ } split /,/, $tag;
    if ( $title && @tags && $contents ) {

        $post->title   ($title)    unless $post->title    eq $title;
        $post->contents($contents) unless $post->contents eq $contents;
        $post->update;

        $c->forward('delete_tags', [ $post ] );      # 이전 태그 제거
        $c->forward('add_tags', [ $post, \@tags ] ); # 새로운 태그 등록

        $c->flash->{status_msg} = "'$title' 글을 고쳤습니다.";
        $c->response->redirect( $c->uri_for("/id/$id") );
    }
    else {
        # 템플릿에서 META를 처리할 수 없으므로 title 설정
        $c->stash->{title} = "[고치기] ".$post->title;

        $c->request->params->{title}    = $post->title;
        $c->request->params->{tags}     = join ', ', map { $_->name } $post->tags->all;
        $c->request->params->{contents} = $post->contents;
    }
}

=head2 id_delete

/id/*/delete 체인액션 처리

=cut

sub id_delete :PathPart('delete') :Chained('id_view') :Args(0) {
    my ( $self, $c ) = @_;

    $c->detach('access_denied')
        unless $c->forward('/user/check', [ 'delete' ]);

    my $post = $c->stash->{post};
    my $id   = $c->stash->{id};

    # 추후 지우기 확인 페이지 생성 필요
    # 템플릿에서 META를 처리할 수 없으므로 title 설정
    my $title = $post->title;
    #$c->stash->{title} = "[지우기] $title";

    $c->forward('delete_tags', [ $post ] ); # 이전 태그 제거
    $post->delete;

    $c->flash->{status_msg} = "'$title' 글을 지웠습니다.";
    $c->response->redirect( $c->uri_for('/recent') );
}

=head2 add_tags

태그 더하기

=cut

sub add_tags :Private {
    my ( $self, $c ) = @_;
    my $post     = $c->request->args->[0];
    my $tags_ref = $c->request->args->[1];

    for my $tag_str ( @$tags_ref ) {
        my $tag = $c->model('DB::Tags')->find_or_new({name => $tag_str});
        $tag->update_or_insert;

        my $post_tag = $c->model('DB::PostTags')->find_or_new({
            post_id => $post->id,
            tag_id  => $tag->id,
        });
        $post_tag->update_or_insert;
    }
}

=head2 delete_tags

태그 지우기

=cut

sub delete_tags :Private {
    my ( $self, $c ) = @_;
    my $post = $c->request->args->[0];

    while ( my $tag_rs = $post->tags->next ) {

        $c->log->debug( 'deleting tag: '.$tag_rs->name );

        my $tag = $c->model('DB::Tags')->find({name => $tag_rs->name});
        if ( $tag ) {

            # post_tags 테이블에서 제거
            my $post_tag = $tag->post_tags->find( { post_id => $post->id } );
            $post_tag->delete if $post_tag;

            # 태그 관련해서 post_tags에
            # 하나의 포스트도 없을 경우 태그 제거
            $tag->delete unless $tag->posts;
        }
    }
}

=head2 access_denied

Catalyst::Plugin::Authorization::ACL 접근금지 예외 처리

=cut

sub access_denied :Private {
    my ( $self, $c ) = @_;

    # 실패한 액션이 고치기 또는 삭제인 경우
    # 해당 식별번호의 글을 보여준다.
    my $path_info = $c->request->path_info;
    if ( $path_info =~ m{^id/(.*?)/(edit|delete)} ) {
        my $id = $1;
        $c->flash->{error_msg} = '권한이 없습니다!';
        $c->response->redirect( $c->uri_for("/id/$id") );
    }
    else {
        $c->stash->{error_msg} = '권한이 없습니다!';
        $c->stash->{template} = 'recent/index.tt2';
        $c->forward('/recent/index');
    }
}


=head1 AUTHOR

Keedi Kim,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
