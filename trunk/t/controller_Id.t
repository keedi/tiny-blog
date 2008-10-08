use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'TinyBlog' }
BEGIN { use_ok 'TinyBlog::Controller::Id' }

ok( request('/id')->is_success, 'Request should succeed' );


