#!/bin/bash

set -eu
PGVERSION=$1
PORT=$2
IMPORT_FILE=$3
docker rm -f spi_dev_"$PGVERSION"
docker run --name spi_dev_"$PGVERSION" -e POSTGRES_DB=spi_dev -e POSTGRES_USER=spi_dev -e POSTGRES_PASSWORD=xxx -p "$PORT":5432 -d postgres:"$PGVERSION"-alpine
echo "Giving Postgres a moment to launch ..."
sleep 5
echo "Creating Azure roles"
PGPASSWORD=xxx psql -h "${HOST:-localhost}" -p "$PORT" -U spi_dev -d spi_dev -c 'CREATE ROLE azure_pg_admin; CREATE ROLE azuresu;'
echo "Importing"
PGPASSWORD=xxx pg_restore --no-owner -h "${HOST:-localhost}" -p "$PORT" -U spi_dev -d spi_dev < "$IMPORT_FILE"
