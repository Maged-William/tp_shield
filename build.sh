#!/bin/sh
set -e

WORKSPACE=${WORKSPACE_DIR:-/mnt/Data/DIY/trackpoint/zmk/zmk-workspace}
BOARD=${BOARD:-nice_nano//zmk}
SHIELD=${SHIELD:-trackpoint}

mkdir -p "$WORKSPACE"

docker run --rm \
  -e BOARD="$BOARD" \
  -e SHIELD="$SHIELD" \
  -v "$PWD":/repo \
  -v "$WORKSPACE":/workspace \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  sh -c '
    set -e
    git config --global --add safe.directory '\''*'\''
    git config --global http.version HTTP/1.1
    cp -r /repo/config .
    if [ -d .west ]; then
      echo "workspace exists, skipping west init"
    else
      west init -l config
    fi

    west update
    west zephyr-export
    rm -rf build
    west build -s zmk/app -d build \
      -b "$BOARD" -- \
      -DZMK_EXTRA_MODULES="/repo" \
      -DZMK_CONFIG=/workspace/config \
      -DSHIELD="$SHIELD"
    cp build/zephyr/zmk.uf2 /repo/
  '
