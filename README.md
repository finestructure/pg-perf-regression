## Run PostgresNIO perf tests

Run the test via `./run-perf-test.sh <postgres-version>`, where `<postgres-version>` is for example `13` or `14`.

For example:

```
❯ ./run-perf-test.sh 13
spi_test
05e245a6d8e40eb4720bf13fd15d92417f01aaee242fa61aa303bb2cd6a5eadb
Building...
Building for debugging...
[1/1] Write swift-version-117DEE11B69C53C9.txt
Build complete! (1.94s)
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
05e245a6d8e4   postgres:13-alpine   "docker-entrypoint.s…"   2 seconds ago   Up 2 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   spi_test
Warm-up run...
Elapsed: createSnapshot(original:snapshot:) 8.430004119873047
Elapsed: createSnapshot(original:snapshot:) 8.610010147094727
Elapsed: createSnapshot(original:snapshot:) 8.718013763427734
Elapsed: createSnapshot(original:snapshot:) 10.769009590148926
Elapsed: createSnapshot(original:snapshot:) 9.420037269592285
Elapsed: createSnapshot(original:snapshot:) 9.361028671264648
Elapsed: createSnapshot(original:snapshot:) 11.000990867614746
Elapsed: createSnapshot(original:snapshot:) 9.75799560546875
Elapsed: createSnapshot(original:snapshot:) 13.123035430908203
Elapsed: createSnapshot(original:snapshot:) 11.572003364562988
```

```
❯ ./run-perf-test.sh 14
spi_test
07af3d73827e1116d48cc06552155d769c911252ea5c98efcfb75acfa1bce1f6
Building...
Building for debugging...
[1/1] Write swift-version-117DEE11B69C53C9.txt
Build complete! (2.11s)
CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS                                       NAMES
07af3d73827e   postgres:14-alpine   "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   spi_test
Warm-up run...
Elapsed: createSnapshot(original:snapshot:) 64.03696537017822
Elapsed: createSnapshot(original:snapshot:) 63.56799602508545
Elapsed: createSnapshot(original:snapshot:) 56.68604373931885
Elapsed: createSnapshot(original:snapshot:) 55.83298206329346
Elapsed: createSnapshot(original:snapshot:) 62.60693073272705
Elapsed: createSnapshot(original:snapshot:) 64.62693214416504
Elapsed: createSnapshot(original:snapshot:) 61.77198886871338
Elapsed: createSnapshot(original:snapshot:) 59.41903591156006
Elapsed: createSnapshot(original:snapshot:) 63.24005126953125
Elapsed: createSnapshot(original:snapshot:) 64.03601169586182
```