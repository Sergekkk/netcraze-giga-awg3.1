#!/usr/bin/env bash
#
# 01_prepare_sdk.sh: Setup Keenetic SDK 5.00 for KN-1012 (MT7981)
#

set -euo pipefail

WORKDIR="${WORKDIR:-/work}"
SDK_DIR="${WORKDIR}/keenetic-sdk"
SDK_REPO="https://github.com/keenetic/keenetic-sdk.git"
SDK_BRANCH="5.00"
TARGET_MODEL="KN-1012"

echo "=== [Step 1] Preparing Keenetic SDK ($SDK_BRANCH) for $TARGET_MODEL ==="

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ ! -d "$SDK_DIR/.git" ]; then
    echo "Cloning Keenetic SDK ($SDK_BRANCH)..."
    git clone --depth 1 -b "$SDK_BRANCH" "$SDK_REPO" "$SDK_DIR"
fi

cd "$SDK_DIR"

if [ -f "./unpack.sh" ]; then
    echo "Unpacking SDK archives..."
    ./unpack.sh
fi

echo "Configuring SDK for target $TARGET_MODEL..."
if [ -f "./configure.sh" ]; then
    ./configure.sh -pmanual "$TARGET_MODEL" || true
fi

echo "Keenetic SDK prepared successfully."
