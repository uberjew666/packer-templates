#!/bin/sh -eux

UBUNTU_VERSION="`lsb_release -r | awk '{print $2}'`";
MAJOR_VERSION="`echo $UBUNTU_VERSION | awk -F. '{print $1}'`";

if [ "$MAJOR_VERSION" -le "15" ] && [ "$UBUNTU_VERSION" != "15.10" ]; then
  echo "Disabling automatic udev rules for network interfaces in Ubuntu"
  # Disable automatic udev rules for network interfaces in Ubuntu,
  # source: http://6.ptmc.org/164/
  rm -f /etc/udev/rules.d/70-persistent-net.rules;
  mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
  rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
  rm -rf /dev/.udev/ /var/lib/dhcp3/* /var/lib/dhcp/*;
fi

# Adding a 2 sec delay to the interface up, to make the dhclient happy
echo "pre-up sleep 2" >> /etc/network/interfaces
sed -i "s/ens33/eth0/g" /etc/network/interfaces

# Disable DNS reverse lookup
echo "UseDNS no" >> /etc/ssh/sshd_config