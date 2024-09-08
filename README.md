## Set up test DBs

- Obtain DB dump file `spi_prod-2024-09-01.dump`
- Run `setup-dbs.sh`

## Run pure SQL perf tests

- Run `run-sql-perf-test.sh`

## Run PostgresNIO perf tests

- Run `swift run`

NB: We're specifically _not_ running in release mode, because the performance regression impacts our running of our _test suite_.
