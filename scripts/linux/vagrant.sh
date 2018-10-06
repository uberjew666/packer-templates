#!/bin/sh

# Set up sudo for vagrant user
echo 'vagrant ALL=NOPASSWD:ALL' > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# Install vagrant key
mkdir -pm 700 /home/vagrant/.ssh
wget -e use_proxy=yes --no-check-certificate https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh