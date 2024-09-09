#!/bin/bash

for PORT in 6432 7432 8432; do
    echo "Testing DB on port $PORT"
    for _ in {1..10}; do
        env PGPASSWORD=xxx time psql -U spi_dev -d spi_dev --host localhost --port "$PORT" -f ./scripts/perf-test.sql > /dev/null
    done
done