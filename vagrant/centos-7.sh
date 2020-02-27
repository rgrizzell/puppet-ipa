#!/bin/sh
echo I am provisioning...
export FACTER_is_vagrant='true'
export PATH=$PATH:/opt/puppetlabs/bin

curl https://raw.githubusercontent.com/Puppet-Finland/scripts/3c1cf163edeebceebd4a29c7c28e6e3a4a11c319/bootstrap/linux/install-puppet.sh -o install-puppet.sh
/bin/sh install-puppet.sh
/bin/yum -y upgrade

# Recent CentOS images have NetworkManager enabled. As it breaks IPA server's
# /etc/resolv.conf we don't want to use it.
puppet apply -e "service { 'NetworkManager': ensure => 'stopped', enable => false, }"
