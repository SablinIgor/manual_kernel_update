#!/bin/bash

set -e
set -x

yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

yum --enablerepo elrepo-kernel install kernel-ml-devel -y

## CentOS and Red Hat (RHEL) example ##
KERN_DIR=/usr/src/kernels/5.3.8

## Export KERN_DIR ##
export KERN_DIR

echo "Install VBoxGuestAdditions"
cd ~

sudo yum -y install bzip2 make perl dkms

wget https://www.virtualbox.org/download/testcase/VBoxGuestAdditions_6.0.15-134343.iso

sudo mount -o loop,ro ~/VBoxGuestAdditions_6.0.15-134343.iso /mnt/

sudo /mnt/VBoxLinuxAdditions.run --nox11 || true

sudo umount /mnt/

rm -rf ~/VBoxGuestAdditions*.iso
