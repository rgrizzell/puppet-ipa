#!/bin/sh
DISTRO=$1
echo I am provisioning...
export FACTER_is_vagrant='true'
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-$DISTRO.deb
dpkg -i puppetlabs-release-pc1-$DISTRO.deb
apt-get update
apt-get -y install puppet-agent
export PATH=$PATH:/opt/puppetlabs/bin
puppet module install puppetlabs-concat
puppet module install puppetlabs-stdlib
puppet module install crayfishx-firewalld
puppet module install puppet-selinux
puppet module install saz-resolv_conf
if [ -d /tmp/modules/easy_ipa ]; then rm -rf /tmp/modules/easy_ipa; fi
mkdir -p /tmp/modules/easy_ipa
cp -r /vagrant/* /tmp/modules/easy_ipa
