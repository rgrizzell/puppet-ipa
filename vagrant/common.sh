#!/bin/sh
echo I am provisioning...
export FACTER_is_vagrant='true'
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent yum-utils
yum-config-manager --save --setopt=puppetlabs-pc1.skip_if_unavailable=true
export PATH=$PATH:/opt/puppetlabs/bin
puppet module install puppetlabs-concat
puppet module install puppetlabs-stdlib
puppet module install crayfishx-firewalld
puppet module install puppet-selinux
puppet module install saz-resolv_conf
if [ -d /tmp/modules/easy_ipa ]; then rm -rf /tmp/modules/easy_ipa; fi
mkdir -p /tmp/modules/easy_ipa
cp -r /vagrant/* /tmp/modules/easy_ipa
