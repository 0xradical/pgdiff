#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE SCHEMA IF NOT EXISTS "app";

  CREATE TYPE app.user_status AS ENUM (
    'enabled',
    'disabled'
  );
EOSQL
