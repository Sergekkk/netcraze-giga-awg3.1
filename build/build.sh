#!/usr/bin/env bash
#
# Master Build Script: Builds AmneziaWG v3 kernel module and tools for Keenetic KN-1012
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export WORKDIR="${WORKDIR:-$(pwd)/workspace}"
export OUTPUT_DIR="${OUTPUT_DIR:-$(pwd)/output}"

mkdir -p "$WORKDIR" "$OUTPUT_DIR"

echo "=========================================================="
echo " Starting Full Automated Build for Keenetic KN-1012 AWG3   "
echo " Working Directory: $WORKDIR"
echo " Output Directory : $OUTPUT_DIR"
echo "=========================================================="

bash "$SCRIPT_DIR/scripts/01_prepare_sdk.sh"
bash "$SCRIPT_DIR/scripts/02_build_kernel.sh"
bash "$SCRIPT_DIR/scripts/03_build_module.sh"
bash "$SCRIPT_DIR/scripts/04_build_tools.sh"

echo ""
echo "=========================================================="
echo " BUILD FINISHED SUCCESSFULLY!                             "
echo " Artifacts located in: $OUTPUT_DIR"
echo " - amneziawg.ko (Kernel module)"
echo " - awg          (User-space CLI)"
echo "=========================================================="
ls -lh "$OUTPUT_DIR"
