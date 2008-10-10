CREATE TABLE users (
    id          INTEGER,
    username    TEXT,
    password    TEXT,
    nick        TEXT,
    email       TEXT,
    active      INTEGER,

    PRIMARY KEY ( id )
);

CREATE TABLE roles (
    id          INTEGER,
    role        TEXT,

    PRIMARY KEY ( id )
);

CREATE TABLE user_roles (
    user_id     INTEGER,
    role_id     INTEGER,

    PRIMARY KEY ( user_id, role_id )
);

INSERT INTO roles VALUES ( 1, 'admin' );
INSERT INTO roles VALUES ( 2, 'writer' );
INSERT INTO roles VALUES ( 3, 'reader' );
