CREATE ROLE "anonymous" LOGIN;
CREATE ROLE "user" LOGIN;
CREATE ROLE "admin" LOGIN;

-- public api used in developer dash, user dash,
-- uses JWT token for authentication, role "user"
CREATE SCHEMA IF NOT EXISTS api;
-- public api used in admin
-- uses JWT token for authentication, role "admin"
CREATE SCHEMA IF NOT EXISTS api_admin_v1;
-- public api used in course api
-- uses API key for authentication, role "anonymous"
CREATE SCHEMA IF NOT EXISTS api_developer_v1;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS api_keys;
CREATE SCHEMA IF NOT EXISTS jwt;
CREATE SCHEMA IF NOT EXISTS triggers;
CREATE SCHEMA IF NOT EXISTS settings;
CREATE SCHEMA IF NOT EXISTS subsets;
CREATE SCHEMA IF NOT EXISTS bi;
CREATE SCHEMA IF NOT EXISTS transliterate;

-- pgFormatter-ignore
CREATE EXTENSION IF NOT EXISTS citext      WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plpgsql     WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pgcrypto    WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS unaccent    WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pg_trgm     WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plv8        WITH SCHEMA pg_catalog;

CREATE AGGREGATE array_accum (anyarray)
(
  sfunc = array_cat,
  stype = anyarray,
  initcond = '{}'
);

CREATE DOMAIN app.domain AS CITEXT;

ALTER DOMAIN app.domain ADD CONSTRAINT domain__must_be_a_domain CHECK ( value ~ '^([a-z0-9\-\_]+\.)+[a-z]+$' );

CREATE DOMAIN app.username AS CITEXT;

ALTER DOMAIN app.username ADD CONSTRAINT username__format CHECK (NOT(value ~* '[^0-9a-zA-Z\.\-\_]'));
ALTER DOMAIN app.username ADD CONSTRAINT username__consecutive_dash CHECK (NOT(value ~* '--'));
ALTER DOMAIN app.username ADD CONSTRAINT username__consecutive_underline CHECK (NOT(value ~* '__'));
ALTER DOMAIN app.username ADD CONSTRAINT username__boundary_dash CHECK (NOT(value ~* '^-' OR value ~* '-$'));
ALTER DOMAIN app.username ADD CONSTRAINT username__boundary_underline CHECK (NOT(value ~* '^_' OR value ~* '_$'));
ALTER DOMAIN app.username ADD CONSTRAINT username__length_upper CHECK (LENGTH(value) <= 15);

CREATE TYPE app.answers AS ENUM (
  'unknown',
  'yes',
  'maybe',
  'no'
);

CREATE TYPE app.api_key_status AS ENUM (
  'enabled',
  'disabled',
  'blacklisted'
);

CREATE TYPE app.provider_created_for AS ENUM (
  'api',
  'system'
);

CREATE TYPE app.composite AS (
  status app.api_key_status,
  answer app.answers
);

CREATE TYPE app.provider_logo AS (
  id uuid,
  provider_id uuid,
  file varchar,
  user_account_id bigint,
  created_at timestamptz,
  updated_at timestamptz,
  fetch_url text,
  upload_url text,
  file_content_type varchar
);

CREATE TYPE course_areas AS ENUM ('unclassified', 'tech', 'non-tech');

CREATE TYPE app.authority_confirmation_method AS ENUM (
  'dns',
  'html'
);

CREATE OR REPLACE FUNCTION app.life() RETURNS integer AS $$
  return 42;
$$ LANGUAGE plv8;


CREATE OR REPLACE FUNCTION app.everything() RETURNS integer AS $$
  return 42;
$$ LANGUAGE plv8;

CREATE FUNCTION add(integer, integer) RETURNS integer
    AS 'select $1 + $2;'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;

CREATE TABLE app.user_accounts (
  id                      bigserial    PRIMARY KEY,
  email                   varchar      DEFAULT ''::varchar NOT NULL,
  sign_in_count           integer      DEFAULT 0           NOT NULL CHECK (add(sign_in_count,1) > 2),
  current_sign_in_at      timestamptz,
  last_sign_in_at         timestamptz,
  current_sign_in_ip      inet,
  last_sign_in_ip         inet,
  tracking_data           json         DEFAULT '{}'::json,
  autogen_email_for_oauth boolean DEFAULT false NOT NULL,
  created_at              timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz  DEFAULT NOW()       NOT NULL
);

CREATE TABLE app.admin_accounts (
  id                      bigserial    PRIMARY KEY,
  email                   varchar      DEFAULT ''::varchar NOT NULL,
  signin_count            integer      DEFAULT 0           NOT NULL,
  signout_count           integer      DEFAULT 1           NOT NULL,
  api_key                 varchar      DEFAULT public.uuid_generate_v4() NOT NULL,
  api_key_status          app.api_key_status DEFAULT 'enabled'::app.api_key_status,
  current_sign_in_at      timestamptz,
  last_sign_in_at         timestamptz,
  current_sign_in_ip      inet,
  last_sign_in_ip         inet,
  tracking_data           json         DEFAULT '{}'::json,
  autogen_email_for_oauth boolean DEFAULT false NOT NULL,
  created_at              timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz  DEFAULT NOW()       NOT NULL
);

CREATE VIEW api.admin_accounts AS (
  SELECT * FROM app.admin_accounts
);

CREATE UNIQUE INDEX index_email_on_users
ON app.user_accounts
USING btree (email);