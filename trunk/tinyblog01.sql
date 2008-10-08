CREATE TABLE users (
    id          INTEGER PRIMARY KEY,
    username    TEXT,
    password    TEXT,
    nick        TEXT,
    email       TEXT,
    active      INTEGER
);

CREATE TABLE roles (
    id          INTEGER PRIMARY KEY,
    role        TEXT
);

CREATE TABLE user_roles (
    user_id     INTEGER,
    role_id     INTEGER,
    PRIMARY KEY ( user_id, role_id )
);
