#!/usr/bin/env bash
#
# 04_build_tools.sh: Cross-compile awg user-space CLI utility
#

set -euo pipefail

WORKDIR="${WORKDIR:-/work}"
OUTPUT_DIR="${OUTPUT_DIR:-${WORKDIR}/out}"
AWG_TOOLS_REPO="https://github.com/amnezia-vpn/amneziawg-tools.git"
AWG_TOOLS_DIR="${WORKDIR}/amneziawg-tools"

SDK_DIR="${WORKDIR}/keenetic-sdk"
TOOLCHAIN_BIN="$(find "$SDK_DIR/staging_dir" -maxdepth 3 -type d -name 'bin' | grep 'toolchain' | head -n 1)"

if [ -n "$TOOLCHAIN_BIN" ]; then
    export PATH="$TOOLCHAIN_BIN:$PATH"
fi

echo "=== [Step 4] Building amneziawg-tools (awg binary) ==="

mkdir -p "$OUTPUT_DIR"
cd "$WORKDIR"

if [ ! -d "$AWG_TOOLS_DIR/.git" ]; then
    echo "Cloning amneziawg-tools..."
    git clone "$AWG_TOOLS_REPO" "$AWG_TOOLS_DIR"
fi

cd "$AWG_TOOLS_DIR/src"

echo "Compiling awg CLI..."
make clean || true
make CC=aarch64-ndms-linux-musl-gcc \
     LD=aarch64-ndms-linux-musl-ld \
     AR=aarch64-ndms-linux-musl-ar \
     STRIP=aarch64-ndms-linux-musl-strip \
     CFLAGS="-O2 -pipe"

if [ -f "awg" ]; then
    echo "SUCCESS: awg binary successfully compiled!"
    cp -vf awg "${OUTPUT_DIR}/awg"
    aarch64-ndms-linux-musl-strip "${OUTPUT_DIR}/awg" || true
    ls -lh "${OUTPUT_DIR}/awg"
else
    echo "ERROR: awg binary was not produced!"
    exit 1
fi
