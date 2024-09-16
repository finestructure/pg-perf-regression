#!/bin/bash

set -eu

PGVERSION=$1

docker rm -f spi_test
docker run --name spi_test \
    -e POSTGRES_DB=spi_test \
    -e POSTGRES_USER=spi_test \
    -e POSTGRES_PASSWORD=xxx \
    -e PGDATA=/pgdata \
    --tmpfs /pgdata:rw,noexec,nosuid,size=1024m \
    -p 5432:5432 \
    -d \
    postgres:$PGVERSION-alpine

echo "Building..."
if ! swift build --build-tests
then
    echo "Build failed"
    exit 1
fi
docker ps

echo "Warm-up run..."
swift test --skip-build --disable-automatic-resolution --filter PerfTest.test1 > /dev/null 2>&1

for _ in {1..10}; do
    swift test --skip-build --disable-automatic-resolution --filter PerfTest.test1 2>&1 | grep "Elapsed:"
done


