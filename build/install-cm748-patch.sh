#!/usr/bin/env bash 

set -oeux pipefail 

echo "Installing prerequisites for CM748 patch..."
dnf install -y git dkms kernel-devel gcc 

echo "Cloning CM748 Bluetooth patch repository..."
git clone https://github.com/nwrafael/CM748-ugreen-bluetooth-adapter-patch-linux.git /tmp/cm748-patch 

echo "Building and registering the kernel module driver..."
cd /tmp/cm748-patch
make
mkdir -p /usr/lib/firmware/
cp -r firmware/* /usr/lib/firmware/
make install 

echo "Cleaning up temporary build artifacts..."
rm -rf /tmp/cm748-patch