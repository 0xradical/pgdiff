#!/bin/bash
set -e

cat /setup.sql | $PSQL_PIPE | psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"
