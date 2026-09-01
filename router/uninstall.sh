#!/bin/sh
#
# uninstall.sh: Clean uninstaller for AmneziaWG v3 from Keenetic OS
#

set -eu

echo "Stopping AmneziaWG service..."
if [ -x "/opt/etc/init.d/S99awg3" ]; then
    /opt/etc/init.d/S99awg3 stop || true
fi

echo "Removing installed service and splitter..."
rm -f /opt/etc/init.d/S99awg3
rm -f /opt/bin/awg3-split-config

echo "Do you want to delete /opt/etc/awg3 configuration files? (y/N)"
read -r answer
case "$answer" in
    [yY]|[yY][eE][sS])
        rm -rf /opt/etc/awg3
        echo "Configuration removed."
        ;;
    *)
        echo "Configuration preserved in /opt/etc/awg3."
        ;;
esac

echo "AmneziaWG v3 uninstalled."
