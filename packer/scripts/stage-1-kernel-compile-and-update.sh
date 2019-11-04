#!/bin/bash

set -e
set -x

# Install dependencies
echo "Install deps"
yum install -y wget gcc flex bison ncurses-devel openssl-devel bc elfutils-libelf-devel perl

cd /usr/src/

echo "Download archive"
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz
tar xf linux-5.3.8.tar.xz

ln -s linux-5.3.8 linux

rm -rf linux-5.3.8.tar.xz

cp /boot/config-3* /usr/src/linux/.config

# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10*

cd linux

echo "Make oldconfig"
yes "" | make oldconfig

echo "Start make"
make --jobs=6
make modules

echo "Start install"
make modules_install
make install

# Update GRUB

echo "Update GRUB"
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."

# Reboot VM

shutdown -r now
