PRAGMA fireign_keys = ON;

CREATE TABLE user (
    id          INTEGER PRIMARY KEY,
    username    TEXT NOT NULL,
    password    TEXT NOT NULL,
    email       TEXT NOT NULL,

    customer_id TEXT DEFAULT NULL,
    api_key     TEXT DEFAULT NULL,
    api_secret  TEXT DEFAULT NULL,

    create_date TEXT DEFAULT NULL,
    update_date TEXT DEFAULT NULL,
    UNIQUE (email)
);

CREATE TABLE role (
    id   INTEGER PRIMARY KEY,
    role TEXT
);

INSERT INTO role VALUES (1, 'user');
INSERT INTO role VALUES (2, 'admin');

CREATE TABLE user_role (
    user_id INTEGER REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    role_id INTEGER REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE campaign (
    id          INTEGER PRIMARY KEY,
    user_id     INTEGER REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    str_id      TEXT NOT NULL,
    name        TEXT NOT NULL,
    create_date TEXT DEFAULT NULL,
    update_date TEXT DEFAULT NULL
);

CREATE TABLE target (
    id          INTEGER PRIMARY KEY,
    url         TEXT NOT NULL,
    create_date TEXT DEFAULT NULL,
    update_date TEXT DEFAULT NULL
);

CREATE TABLE adgroup (
    id          INTEGER PRIMARY KEY,
    campaign_id INTEGER REFERENCES campaign(id) ON DELETE CASCADE ON UPDATE CASCADE,
    target_id   INTEGER REFERENCES target(id)   ON DELETE CASCADE ON UPDATE CASCADE,
    str_id      TEXT NOT NULL,
    name        TEXT NOT NULL,
    create_date TEXT DEFAULT NULL,
    update_date TEXT DEFAULT NULL
);

CREATE TABLE rank (
    id           INTEGER PRIMARY KEY,
    rank         INTEGER DEFAULT NULL,
    tobe         INTEGER DEFAULT NULL,
    bid_max      INTEGER DEFAULT NULL,
    bid_min      INTEGER DEFAULT NULL,
    bid_interval INTEGER DEFAULT NULL,
    create_date  TEXT DEFAULT NULL,
    update_date  TEXT DEFAULT NULL
);

CREATE TABLE adkeyword (
    id          INTEGER PRIMARY KEY,
    adgroup_id  INTEGER REFERENCES adgroup(id)   ON DELETE CASCADE ON UPDATE CASCADE,
    rank_id     INTEGER REFERENCES adkeyword(id) ON DELETE CASCADE ON UPDATE CASCADE,
    str_id      TEXT NOT NULL,
    name        TEXT NOT NULL,
    bid_amt     INTEGER DEFAULT 0,
    on_off      INTEGER DEFAULT 0,
    create_date TEXT DEFAULT NULL,
    update_date TEXT DEFAULT NULL
);
