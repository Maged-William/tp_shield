#!/bin/sh
set -e

WORKSPACE=${WORKSPACE_DIR:-/tmp/zmk-workspace}
BOARD=${BOARD:-nice_nano//zmk}
SHIELD=${SHIELD:-trackpoint}

mkdir -p "$WORKSPACE"

MODULE_DIR="/mnt/Data/DIY/trackpoint/zmk/tp/magedwilliam-kb_zmk_ps2_mouse_trackpoint_dirver"

docker run --rm \
  -e BOARD="$BOARD" \
  -e SHIELD="$SHIELD" \
  -v "$PWD":/repo \
  -v "$MODULE_DIR":/tp-module \
  -v "$WORKSPACE":/workspace \
  -w /workspace \
  zmkfirmware/zmk-build-arm:stable \
  sh -c '
    set -e
    git config --global --add safe.directory '*'
    git config --global http.version HTTP/1.1
    cp -r /repo/config .
    if [ -d .west ]; then
      echo "workspace exists, skipping west init"
    else
      west init -l config
    fi
    # Symlink module into workspace so ZMK_EXTRA_MODULES can find it
    ln -sf /tp-module /workspace/kb_zmk_ps2_mouse_trackpoint_driver

    west update
    west zephyr-export
    rm -rf build
    west build -s zmk/app -d build \
      -b "$BOARD" -- \
      -DZMK_EXTRA_MODULES="/repo;/workspace/kb_zmk_ps2_mouse_trackpoint_driver" \
      -DZMK_CONFIG=/workspace/config \
      -DSHIELD="$SHIELD"
    cp build/zephyr/zmk.uf2 /repo/
  '
