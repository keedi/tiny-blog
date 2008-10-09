#!/bin/sh

sqlite3 tinyblog.db < tinyblog01.sql
sqlite3 tinyblog.db < tinyblog02.sql

script/tinyblog_create.pl model DB DBIC::Schema TinyBlog::Schema create=static dbi:SQLite:tinyblog.db
