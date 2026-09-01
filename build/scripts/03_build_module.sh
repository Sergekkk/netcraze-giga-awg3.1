#!/usr/bin/env bash
#
# 03_build_module.sh: Compile amneziawg.ko kernel module
#

set -euo pipefail

WORKDIR="${WORKDIR:-/work}"
OUTPUT_DIR="${OUTPUT_DIR:-${WORKDIR}/out}"
AWG_MODULE_REPO="https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git"
AWG_MODULE_DIR="${WORKDIR}/amneziawg-linux-kernel-module"

if [ -f "${WORKDIR}/build_env.sh" ]; then
    source "${WORKDIR}/build_env.sh"
fi

SDK_DIR="${WORKDIR}/keenetic-sdk"
TOOLCHAIN_BIN="$(find "$SDK_DIR/staging_dir" -maxdepth 3 -type d -name 'bin' | grep 'toolchain' | head -n 1)"

if [ -n "$TOOLCHAIN_BIN" ]; then
    export PATH="$TOOLCHAIN_BIN:$PATH"
fi

if [ -z "${KERNEL_DIR:-}" ]; then
    KERNEL_DIR="$(find "$SDK_DIR/build_dir" -maxdepth 4 -type d -name 'linux-4.9*' | head -n 1)"
fi

echo "=== [Step 3] Building AmneziaWG Kernel Module ==="
echo "Kernel Source : $KERNEL_DIR"
echo "Toolchain Path: $TOOLCHAIN_BIN"

mkdir -p "$OUTPUT_DIR"
cd "$WORKDIR"

if [ ! -d "$AWG_MODULE_DIR/.git" ]; then
    echo "Cloning amneziawg-linux-kernel-module..."
    git clone "$AWG_MODULE_REPO" "$AWG_MODULE_DIR"
fi

cd "$AWG_MODULE_DIR"

# Apply patch if present
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_FILE="${SCRIPT_DIR}/../patches/001-amneziawg-linux49-compat.patch"
if [ -f "$PATCH_FILE" ]; then
    echo "Applying patch: $(basename "$PATCH_FILE")..."
    patch -p1 -N -r - < "$PATCH_FILE" || true
fi

cd "$AWG_MODULE_DIR/src"

echo "Running make for amneziawg.ko..."
make -C "$KERNEL_DIR" \
    M="$(pwd)" \
    ARCH=arm64 \
    CROSS_COMPILE=aarch64-ndms-linux-musl- \
    modules

if [ -f "amneziawg.ko" ]; then
    echo "SUCCESS: amneziawg.ko successfully compiled!"
    cp -vf amneziawg.ko "${OUTPUT_DIR}/amneziawg.ko"
    ls -lh "${OUTPUT_DIR}/amneziawg.ko"
else
    echo "ERROR: amneziawg.ko was not produced!"
    exit 1
fi
