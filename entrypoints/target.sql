CREATE SCHEMA IF NOT EXISTS "bogus";

CREATE TYPE bogus.api_key_status AS ENUM (
  'enabled',
  'disabled',
  'blacklisted'
);

-- here for debugging purposes
CREATE SCHEMA IF NOT EXISTS "pgdiff";
