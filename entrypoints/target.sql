CREATE ROLE "thiago" LOGIN;
CREATE ROLE "anonymous" LOGIN;

CREATE SCHEMA IF NOT EXISTS api;
CREATE SCHEMA IF NOT EXISTS api_admin_v1;
CREATE SCHEMA IF NOT EXISTS api_developer_v1;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS api_keys;
CREATE SCHEMA IF NOT EXISTS jwt;
CREATE SCHEMA IF NOT EXISTS triggers;
CREATE SCHEMA IF NOT EXISTS settings;
CREATE SCHEMA IF NOT EXISTS transliterate;

-- pgFormatter-ignore
CREATE EXTENSION IF NOT EXISTS citext      WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plpgsql     WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS unaccent    WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS hstore      WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pg_trgm     WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plv8        WITH SCHEMA pg_catalog;

CREATE AGGREGATE array_accumm (anyarray)
(
  sfunc = array_cat,
  stype = anyarray,
  initcond = '{}'
);

CREATE DOMAIN app.username AS CITEXT;

ALTER DOMAIN app.username ADD CONSTRAINT username__format CHECK (NOT(value ~* '[^0-9a-zA-Z\.\-\_]'));
ALTER DOMAIN app.username ADD CONSTRAINT username__consecutive_dash CHECK (NOT(value ~* '--'));
ALTER DOMAIN app.username ADD CONSTRAINT username__consecutive_underline CHECK (NOT(value ~* '__'));
ALTER DOMAIN app.username ADD CONSTRAINT username__boundary_dash CHECK (NOT(value ~* '^-' OR value ~* '-$'));
ALTER DOMAIN app.username ADD CONSTRAINT username__boundary_underline CHECK (NOT(value ~* '^_' OR value ~* '_$'));
ALTER DOMAIN app.username ADD CONSTRAINT username__length_upper CHECK (LENGTH(value) <= 15);
ALTER DOMAIN app.username ADD CONSTRAINT username__length_lower CHECK (LENGTH(value) >= 5);
ALTER DOMAIN app.username ADD CONSTRAINT username__lowercased CHECK (value = LOWER(value));

CREATE TYPE app.api_key_status AS ENUM (
  'enabled',
  'disabled',
  'onhold',
  'blacklisted'
);

CREATE TYPE app.provider_created_by AS ENUM (
  'api',
  'system'
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

CREATE OR REPLACE FUNCTION api.life() RETURNS integer AS $$
  return 42;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION app.everything() RETURNS integer AS $$
  return 43;
$$ LANGUAGE plv8;

GRANT EXECUTE ON FUNCTION app.everything() TO "anonymous";

CREATE TABLE app.users (
  id                      bigserial    PRIMARY KEY,
  email                   varchar      DEFAULT ''::varchar NOT NULL,
  sign_in_count           integer      DEFAULT 0           NOT NULL,
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
  sign_in_count           integer      DEFAULT 0           NOT NULL,
  signout_count           integer      DEFAULT 0           NOT NULL,
  domains                 jsonb        DEFAULT '{}'::jsonb,
  current_sign_in_at      timestamptz,
  last_sign_in_at         timestamptz,
  current_sign_in_ip      inet,
  last_sign_in_ip         inet,
  tracking_data           json         DEFAULT '{}'::jsonb,
  autogen_email_for_oauth boolean DEFAULT false NOT NULL,
  created_at              timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz  DEFAULT NOW()       NOT NULL
);