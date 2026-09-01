#!/usr/bin/env bash
#
# 02_build_kernel.sh: Prepare and compile kernel headers & Module.symvers
#

set -euo pipefail

WORKDIR="${WORKDIR:-/work}"
SDK_DIR="${WORKDIR}/keenetic-sdk"

echo "=== [Step 2] Preparing Kernel and Symbols ==="

cd "$SDK_DIR"

# Build toolchain and kernel compilation targets to get exact runtime Module.symvers
echo "Building kernel target prerequisites (this may take time on first run)..."
make target/linux/compile -j"$(nproc)" V=s || {
    echo "make target/linux/compile finished (checking artifacts)..."
}

# Locate Linux kernel directory
KDIR="$(find "$SDK_DIR/build_dir" -maxdepth 4 -type d -name 'linux-4.9*' | head -n 1)"

if [ -z "$KDIR" ] || [ ! -d "$KDIR" ]; then
    echo "Searching in alternate location ~/giga/kernel-49..."
    if [ -d "${WORKDIR}/kernel-49" ]; then
        KDIR="${WORKDIR}/kernel-49"
    fi
fi

if [ -z "$KDIR" ] || [ ! -d "$KDIR" ]; then
    echo "ERROR: Could not locate Linux 4.9 kernel build directory!"
    exit 1
fi

echo "Kernel build directory located at: $KDIR"
echo "KERNEL_DIR=$KDIR" > "${WORKDIR}/build_env.sh"

cd "$KDIR"
if [ ! -f "Module.symvers" ]; then
    echo "Generating Module.symvers..."
    make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-ndms-linux-musl- modules_prepare || true
fi

echo "Kernel preparation completed."
