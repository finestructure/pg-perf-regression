#!/bin/bash

set -eu
PGVERSION=$1
PORT=$2
IMPORT_FILE=$3

POSTGRES_RUN_IMAGE="postgres:$PGVERSION-alpine"
POSTGRES_IMPORT_IMAGE="postgres:16-alpine"

docker rm -f "spi_dev_$PGVERSION"
docker run --name "spi_dev_$PGVERSION" -e POSTGRES_DB=spi_dev -e POSTGRES_USER=spi_dev -e POSTGRES_PASSWORD=xxx -p "$PORT":5432 -d "$POSTGRES_RUN_IMAGE"
echo "Giving Postgres a moment to launch ..."
sleep 3

echo "Creating Azure roles"
psql="docker run --rm -v $PWD:/host -w /host --network=host -e PGPASSWORD=xxx $POSTGRES_IMPORT_IMAGE psql"
$psql -h "${HOST:-localhost}" -p "$PORT" -U spi_dev -d spi_dev -c 'CREATE ROLE azure_pg_admin; CREATE ROLE azuresu;'

echo "Importing"
pg_restore="docker run --rm -i -v $PWD:/host -w /host --network=host -e PGPASSWORD=xxx $POSTGRES_IMPORT_IMAGE pg_restore"
$pg_restore --no-owner -h "${HOST:-localhost}" -p "$PORT" -U spi_dev -d spi_dev < "$IMPORT_FILE"
