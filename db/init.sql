SET NAMES utf8;

DROP DATABASE `searchad`;
CREATE DATABASE `searchad`;
USE `searchad`;

CREATE TABLE user (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username    VARCHAR(128) NOT NULL,
    password    VARCHAR(64) NOT NULL,
    email       VARCHAR(128) NOT NULL,

    customer_id VARCHAR(32) DEFAULT NULL,
    api_key     VARCHAR(128) DEFAULT NULL,
    api_secret  VARCHAR(128) DEFAULT NULL,

    create_date DATETIME DEFAULT NULL,
    update_date DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),
    UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE role (
    id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    role VARCHAR(32) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO role VALUES (1, 'user');
INSERT INTO role VALUES (2, 'admin');

CREATE TABLE user_role (
    user_id INT UNSIGNED NOT NULL,
    role_id INT UNSIGNED NOT NULL,

    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role1 FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role2 FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE campaign (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id     INT UNSIGNED NOT NULL,
    str_id      VARCHAR(64) NOT NULL,
    name        VARCHAR(64) NOT NULL,
    create_date DATETIME DEFAULT NULL,
    update_date DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),
    CONSTRAINT fk_campaign1 FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE target (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    url         VARCHAR(256) NOT NULL,
    create_date DATETIME DEFAULT NULL,
    update_date DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE adgroup (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    campaign_id INT UNSIGNED NOT NULL,
    target_id   INT UNSIGNED NOT NULL,
    str_id      VARCHAR(64) NOT NULL,
    name        VARCHAR(64) NOT NULL,
    create_date DATETIME DEFAULT NULL,
    update_date DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),
    CONSTRAINT fk_adgroup1 FOREIGN KEY (campaign_id) REFERENCES campaign (id) ON DELETE CASCADE,
    CONSTRAINT fk_adgroup2 FOREIGN KEY (target_id)   REFERENCES target (id)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE rank (
    id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    rank         INT DEFAULT 0,
    tobe         INT DEFAULT 0,
    bid_max      INT DEFAULT 0,
    bid_min      INT DEFAULT 0,
    bid_interval INT DEFAULT 0,
    bid_amt      INT DEFAULT 0,
    on_off       INT DEFAULT 0,
    create_date  DATETIME DEFAULT NULL,
    update_date  DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE adkeyword (
    id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    adgroup_id  INT UNSIGNED NOT NULL,
    rank_id     INT UNSIGNED NOT NULL,
    str_id      VARCHAR(64) NOT NULL,
    name        VARCHAR(64) NOT NULL,
    max_depth   INT NOT NULL,
    create_date DATETIME DEFAULT NULL,
    update_date DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),
    CONSTRAINT fk_keyword1 FOREIGN KEY (adgroup_id) REFERENCES adgroup (id) ON DELETE CASCADE,
    CONSTRAINT fk_keyword2 FOREIGN KEY (rank_id)    REFERENCES rank (id)    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
