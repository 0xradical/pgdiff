#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE SCHEMA IF NOT EXISTS "app";

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
    reset_password_token    varchar,
    reset_password_sent_at  timestamptz,
    remember_created_at     timestamptz,
    sign_in_count           integer      DEFAULT 0           NOT NULL,
    current_sign_in_at      timestamptz,
    last_sign_in_at         timestamptz,
    current_sign_in_ip      inet,
    last_sign_in_ip         inet,
    tracking_data           json         DEFAULT '{}'::json,
    confirmation_token      varchar,
    confirmed_at            timestamptz,
    confirmation_sent_at    timestamptz,
    unconfirmed_email       varchar,
    failed_attempts         integer      DEFAULT 0           NOT NULL,
    unlock_token            varchar,
    locked_at               timestamptz,
    destroyed_at            timestamptz,
    autogen_email_for_oauth boolean DEFAULT false NOT NULL,
    created_at              timestamptz  DEFAULT NOW()       NOT NULL,
    updated_at              timestamptz  DEFAULT NOW()       NOT NULL
  );
EOSQL