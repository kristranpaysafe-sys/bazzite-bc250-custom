#!/usr/bin/env bash 

set -oeux pipefail 

echo "Installing kernel build dependencies..."
dnf install -y git patch wget tar xz dkms gcc make bison flex elfutils-libelf-devel openssl-devel bc dwarves kernel-devel-6.17.7-ba29.fc43.x86_64 

echo "Downloading matching 6.17.7 kernel source..."
mkdir -p /tmp/kernel-build
cd /tmp/kernel-build
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.7.tar.xz
tar -xf linux-6.17.7.tar.xz
cd linux-6.17.7 

echo "Fetching the raw CM748 kernel patch..."
wget https://raw.githubusercontent.com/nwrafael/CM748-ugreen-bluetooth-adapter-patch-linux/main/0001-bluetooth-disable-read-local-ext-features.patch 

echo "Applying the patch to the Bluetooth stack..."
patch -p1 < 0001-bluetooth-disable-read-local-ext-features.patch 

echo "Preparing kernel config environment..."
cp /lib/modules/6.17.7-ba29.fc43.x86_64/build/.config .config || make olddefconfig
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
make modules_prepare
cp /lib/modules/6.17.7-ba29.fc43.x86_64/build/Module.symvers . 

echo "Compiling the patched Bluetooth module..."
make M=net/bluetooth modules 

echo "Replacing the system Bluetooth module..."
TARGET_DIR="/usr/lib/modules/6.17.7-ba29.fc43.x86_64/kernel/net/bluetooth"
mkdir -p "$TARGET_DIR"
cp net/bluetooth/bluetooth.ko "$TARGET_DIR/bluetooth.ko" 

echo "Compressing module for Bazzite storage compliance..."
zstd --rm "$TARGET_DIR/bluetooth.ko" 

echo "Cleaning up temporary kernel build directory..."
rm -rf /tmp/kernel-build
