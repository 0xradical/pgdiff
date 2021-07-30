#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE SCHEMA IF NOT EXISTS "app";
  CREATE SCHEMA IF NOT EXISTS "api";
  CREATE SCHEMA IF NOT EXISTS "funcs";

  CREATE EXTENSION IF NOT EXISTS citext      WITH SCHEMA public;
  CREATE EXTENSION IF NOT EXISTS plpgsql     WITH SCHEMA pg_catalog;
  CREATE EXTENSION IF NOT EXISTS pgcrypto    WITH SCHEMA public;
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
  CREATE EXTENSION IF NOT EXISTS plv8        WITH SCHEMA pg_catalog;

  CREATE ROLE "anonymous";
  CREATE ROLE "admin" LOGIN PASSWORD 'password';
  CREATE ROLE "user" LOGIN;

  CREATE AGGREGATE array_accum (anyarray)
  (
    sfunc = array_cat,
    stype = anyarray,
    initcond = '{}'
  );

  CREATE DOMAIN app.domain AS CITEXT;
  ALTER DOMAIN app.domain ADD CONSTRAINT domain__must_be_a_domain CHECK ( value ~ '^([a-z0-9\-\_]+\.)+[a-z]+$' );

  CREATE DOMAIN app.username AS CITEXT;

  CREATE TYPE app.api_key_status AS ENUM (
    'enabled',
    'disabled',
    'blacklisted'
  );

  CREATE TABLE app.user_accounts (
    id                      bigserial    PRIMARY KEY,
    email                   varchar      DEFAULT ''::varchar NOT NULL,
    encrypted_password      varchar      DEFAULT ''::varchar NOT NULL,
    preferences             json         DEFAULT '{}'::json,
    login_attempts          integer      DEFAULT 0           NOT NULL,
    created_at              timestamptz  DEFAULT NOW()       NOT NULL,
    updated_at              timestamptz  DEFAULT NOW()       NOT NULL
  );

  CREATE OR REPLACE VIEW api.user_accounts AS (
    SELECT * FROM app.user_accounts WHERE created_at >= '2020-01-01'
  );

  CREATE OR REPLACE FUNCTION funcs.answer_to_life() RETURNS TEXT AS \$\$
    // a comment inside the function
    return 42;
  \$\$ LANGUAGE plv8;

  CREATE OR REPLACE FUNCTION api.user_account_instead_of_insert() RETURNS trigger AS \$\$
    var user = plv8.execute(`
      INSERT INTO app.user_accounts (email) VALUES ('\${NEW.email}') RETURNING *;
    `)[0];
    return user;
  \$\$ LANGUAGE plv8;

  CREATE TRIGGER api_user_account_instead_of_insert
    INSTEAD OF INSERT
    ON api.user_accounts
    FOR EACH ROW
      EXECUTE PROCEDURE api.user_account_instead_of_insert();
EOSQL