#!/bin/sh
#
# install.sh: Installer for AmneziaWG v3 on Keenetic OS (Entware)
# Supported platform: Keenetic Giga (KN-1012 / NC-1012) & MT7981 architecture
#

set -eu

echo "========================================================"
echo "    AmneziaWG v3 Installer for Keenetic OS (Entware)   "
echo "========================================================"

# 1. Check Entware environment
if [ ! -d "/opt/bin" ] || [ ! -d "/opt/etc" ]; then
    echo "ERROR: Entware is not installed or /opt is not mounted."
    echo "Please set up Entware on USB storage first."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/5] Creating directories in /opt..."
mkdir -p /opt/bin
mkdir -p /opt/sbin
mkdir -p /opt/lib/modules
mkdir -p /opt/etc/init.d
mkdir -p /opt/etc/awg3/conf/parsed

echo "[2/5] Installing awg3-split-config..."
cp -f "$SCRIPT_DIR/opt/bin/awg3-split-config" /opt/bin/awg3-split-config
chmod 755 /opt/bin/awg3-split-config

echo "[3/5] Installing service init script S99awg3..."
cp -f "$SCRIPT_DIR/opt/etc/init.d/S99awg3" /opt/etc/init.d/S99awg3
chmod 755 /opt/etc/init.d/S99awg3

echo "[4/5] Checking prebuilt binaries..."
if [ -f "$SCRIPT_DIR/../prebuilt/kn-1012/amneziawg.ko" ]; then
    echo "Copying amneziawg.ko -> /opt/lib/modules/..."
    cp -f "$SCRIPT_DIR/../prebuilt/kn-1012/amneziawg.ko" /opt/lib/modules/amneziawg.ko
    chmod 644 /opt/lib/modules/amneziawg.ko
fi

if [ -f "$SCRIPT_DIR/../prebuilt/kn-1012/awg" ]; then
    echo "Copying awg -> /opt/bin/..."
    cp -f "$SCRIPT_DIR/../prebuilt/kn-1012/awg" /opt/bin/awg
    chmod 755 /opt/bin/awg
fi

if [ ! -f "/opt/lib/modules/amneziawg.ko" ]; then
    echo "WARNING: /opt/lib/modules/amneziawg.ko is missing!"
    echo "         Please place your compiled amneziawg.ko into /opt/lib/modules/."
fi

if [ ! -f "/opt/bin/awg" ]; then
    echo "WARNING: /opt/bin/awg is missing!"
    echo "         Please place your compiled awg binary into /opt/bin/."
fi

echo "[5/5] Checking configuration directory..."
if [ ! -f /opt/etc/awg3/conf/*.conf 2>/dev/null ]; then
    if [ -f "$SCRIPT_DIR/opt/etc/awg3/conf/awg3_example.conf" ]; then
        cp -f "$SCRIPT_DIR/opt/etc/awg3/conf/awg3_example.conf" /opt/etc/awg3/conf/awg3_example.conf
        echo "Example configuration copied to /opt/etc/awg3/conf/awg3_example.conf"
    fi
fi

echo ""
echo "========================================================"
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Place your *.conf file(s) into: /opt/etc/awg3/conf/"
echo "2. Start the service: /opt/etc/init.d/S99awg3 start"
echo "3. Check status: /opt/etc/init.d/S99awg3 status (or /opt/bin/awg show)"
echo "========================================================"
