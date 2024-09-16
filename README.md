## Run PostgresNIO perf tests

Run the test via `./run-perf-test.sh <postgres-version> <test>`, where `<postgres-version>` is for example `13` or `14`, and `<test>` is the particular unit test to run (`test1`, `test2`, or `test3`).

For example:

```
❯ ./run-perf-test.sh 13 test1
spi_test
2cd718d72e268014531e9cfdc35fd92aa599baeef60309fe93fdfe531cd1b565
Building...
Building for debugging...
[1/1] Write swift-version-117DEE11B69C53C9.txt
Build complete! (1.94s)
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
2cd718d72e26   postgres:13-alpine   "docker-entrypoint.s…"   2 seconds ago   Up 2 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   spi_test
Warm-up run...
Elapsed: createSnapshot(original:snapshot:) 9.019017219543457
Elapsed: createSnapshot(original:snapshot:) 8.237957954406738
Elapsed: createSnapshot(original:snapshot:) 8.933067321777344
Elapsed: createSnapshot(original:snapshot:) 8.862972259521484
Elapsed: createSnapshot(original:snapshot:) 10.200977325439453
Elapsed: createSnapshot(original:snapshot:) 18.72098445892334
Elapsed: createSnapshot(original:snapshot:) 9.328961372375488
Elapsed: createSnapshot(original:snapshot:) 9.165048599243164
Elapsed: createSnapshot(original:snapshot:) 12.122035026550293
Elapsed: createSnapshot(original:snapshot:) 9.653091430664062
```

```
❯ ./run-perf-test.sh 14 test1
spi_test
3acd4d1c3ea5bd6a3227057352e4795a4d23eb5c2dbf6f5793fc456963cfc7a0
Building...
Building for debugging...
[1/1] Write swift-version-117DEE11B69C53C9.txt
Build complete! (1.95s)
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
3acd4d1c3ea5   postgres:14-alpine   "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   spi_test
Warm-up run...
Elapsed: createSnapshot(original:snapshot:) 61.66696548461914
Elapsed: createSnapshot(original:snapshot:) 65.28592109680176
Elapsed: createSnapshot(original:snapshot:) 61.91599369049072
Elapsed: createSnapshot(original:snapshot:) 61.51294708251953
Elapsed: createSnapshot(original:snapshot:) 60.81497669219971
Elapsed: createSnapshot(original:snapshot:) 58.27903747558594
Elapsed: createSnapshot(original:snapshot:) 59.15999412536621
Elapsed: createSnapshot(original:snapshot:) 58.68804454803467
Elapsed: createSnapshot(original:snapshot:) 59.478044509887695
Elapsed: createSnapshot(original:snapshot:) 61.19108200073242
```