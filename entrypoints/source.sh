#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE SCHEMA "app";

  CREATE ROLE "anonymous";
  CREATE ROLE "admin" LOGIN PASSWORD 'password';
  CREATE ROLE "user" LOGIN;
EOSQL