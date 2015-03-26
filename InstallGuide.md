_TinyBlog Install Guide_

# 서론 #

TinyBlog 설치하기


# 서버와 연동하기 #

아파치2와 TinyBlog 연동하기:
  * Catalyst::Engine::Apache 모듈 설치
  * 자신의 id를 www-data에 속하게 함
  * 파일 권한 조정
```
chmod 775 TinyBlog
chmod 664 TinyBlog/tinyblog.db
chmod 775 TinyBlog/tmp
chmod 660 TinyBlog/tmp/session

chgrp www-data TinyBlog
chgrp www-data TinyBlog/tinyblog.db
chgrp www-data TinyBlog/tmp
chgrp www-data TinyBlog/tmp/session
```

  * 아파치 설정
```
# mod_perl
Alias /tinyblog/static /your_TinyBlog_Location/TinyBlog/root/static
PerlSwitches -I/your_TinyBlog_Location/TinyBlog/lib
<Location /tinyblog>
    SetHandler          modperl
    PerlResponseHandler TinyBlog
</Location>
```