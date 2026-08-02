#!/usr/bin/env bash 

set -oeux pipefail 

echo "Installing light build tools..."
dnf install -y git patch dkms kernel-devel-matched gcc make 

echo "Cloning the driver patch source..."
git clone https://github.com/nwrafael/CM748-ugreen-bluetooth-adapter-patch-linux.git /tmp/cm748-patch 

echo "Creating a standard DKMS configuration structure..."
mkdir -p /usr/src/bluetooth-1.0
cp -r /tmp/cm748-patch/* /usr/src/bluetooth-1.0/ 

echo "Creating the dkms.conf file manually..."
cat << 'EOF' > /usr/src/bluetooth-1.0/dkms.conf
PACKAGE_NAME="bluetooth"
PACKAGE_VERSION="1.0"
BUILT_MODULE_NAME="bluetooth"
DEST_MODULE_LOCATION="/kernel/net/bluetooth"
AUTOINSTALL="yes"
EOF 

echo "Registering, building, and installing via DKMS..."
dkms add -m bluetooth -v 1.0
dkms build -m bluetooth -v 1.0
dkms install -m bluetooth -v 1.0 

echo "Cleaning up temp files..."
rm -rf /tmp/cm748-patch
