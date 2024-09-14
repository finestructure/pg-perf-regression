#!/bin/bash

set -eu
PORT=$1

swift build
exe="$(swift build --show-bin-path)"/pg-perf-regression

echo "Testing on port $PORT"

for _ in {1..10}; do
    $exe "$PORT"
done
