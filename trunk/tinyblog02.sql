CREATE TABLE posts (
    id           INTEGER  NOT NULL,
    created_on   DATETIME NOT NULL,
    updated_on   DATETIME NOT NULL,
    published_on DATETIME NOT NULL,
    title        TEXT     NOT NULL,
    contents     LONGTEXT NOT NULL,

    PRIMARY KEY ( id )
);

CREATE TABLE replies (
    id          INTEGER  NOT NULL,
    author      TEXT     NOT NULL,
    created_on  DATETIME NOT NULL,
    updated_on  DATETIME NOT NULL,
    title       TEXT     NOT NULL,
    contents    LONGTEXT NOT NULL,

    PRIMARY KEY ( id )
);

CREATE TABLE tags (
    id          INTEGER  NOT NULL,
    name        TEXT     NOT NULL,

    PRIMARY KEY ( id )
);

CREATE TABLE post_users (
    post_id     INTEGER NOT NULL,
    user_id     INTEGER NOT NULL,

    PRIMARY KEY ( post_id, user_id )
);

CREATE TABLE post_tags (
    post_id     INTEGER NOT NULL,
    tag_id      INTEGER NOT NULL,

    PRIMARY KEY ( post_id, tag_id )
);

CREATE TABLE post_replies (
    post_id     INTEGER NOT NULL,
    reply_id    INTEGER NOT NULL,

    PRIMARY KEY ( post_id, reply_id )
);
