#!/bin/bash

# Run as root or won't work

INS_DIR=/usr/share/nouveau-bumblebee

echo "Uninstalling files..."
# Executable files
rm -v $INS_DIR/bumblebee
rm -v /usr/bin/optirun
rm -v $INS_DIR/bumblebee-enablecard
rm -v $INS_DIR/bumblebee-disablecard
rm -v /etc/pm/power.d/10-bumblebee-disablecard

# Configuration files
rm -v /etc/bumblebee/xorg.conf.nouveau
rm -v /etc/bumblebee/bumblebee.conf

echo "Uninstall complete. Thank you for testing"

