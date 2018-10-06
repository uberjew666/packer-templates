#!/bin/sh

UBUNTU_VERSION="`lsb_release -r | awk '{print $2}'`";
MAJOR_VERSION="`echo $UBUNTU_VERSION | awk -F. '{print $1}'`";
UBUNTU_CODENAME="`lsb_release -c | awk '{print $2}'`";

if [ "$PACKER_BUILDER_TYPE" = "hyperv-iso" ]; then
  echo "Installing Hyper-V Kernal"
  # install Microsoft best practices
  
  if [ "$MAJOR_VERSION" -le "16" ]; then
    apt-get -y install linux-virtual-lts-$UBUNTU_CODENAME linux-tools-virtual-lts-$UBUNTU_CODENAME linux-cloud-tools-virtual-lts-$UBUNTU_CODENAME
  fi

  if [ "$MAJOR_VERSION" -ge "17" ]; then
    apt-get -y install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual
  fi

  # https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v#use-io-scheduler-noop-for-better-disk-io-performance
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash elevator=noop\"/" /etc/default/grub
  update-grub

  # gen 2 EFI fix - see https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
  cp -r /boot/efi/EFI/ubuntu/ /boot/efi/EFI/boot
  mv /boot/efi/EFI/boot/shimx64.efi /boot/efi/EFI/boot/bootx64.efi
fi

if [ "$PACKER_BUILDER_TYPE" = "vmware-iso" ]; then
  # Install this specific version - Latest version is broken on Ubuntu 16.04
  echo "Installing Open VM tools"
  apt-get install open-vm-tools=2:10.0.7-3227872-2ubuntu1 -y

  # Remove quiet parameter from grub
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub

  # Change disk scheduling to Noop
  sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/GRUB_CMDLINE_LINUX_DEFAULT=\"elevator=noop\"/" /etc/default/grub
  update-grub

  # Disable Kernel module
  echo "blacklist i2c-piix4" >> /etc/modprobe.d/blacklist.conf
fi