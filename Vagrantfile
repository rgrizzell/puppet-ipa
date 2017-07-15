# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

    config.vm.define "vagrant-ipa1" do |box|
        box.vm.box = "bento/centos-7.3"
        box.vm.hostname = 'vagrant-ipa1.vagrant.example.lan'
        # Assign this VM to a host-only network IP, allowing you to access it
        # via the IP.
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 4096
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.35"
        box.vm.network "forwarded_port", guest: 8443, host: 8440

        $script = <<SCRIPT
echo I am provisioning...
export FACTER_is_vagrant='true'
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent
export PATH=$PATH:/opt/puppetlabs/bin
puppet module install puppetlabs-concat
puppet module install puppetlabs-stdlib
puppet module install crayfishx-firewalld
puppet module install puppet-selinux
if [ -d /tmp/modules/ipa ]; then rm -rf /tmp/modules/ipa; fi
mkdir -p /tmp/modules/ipa
cp -r /vagrant/* /tmp/modules/ipa
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "class {'::ipa': \
 ipa_role => 'master',\
 domain => 'vagrant.example.lan',\
 ipa_server_fqdn => 'vagrant-ipa1.vagrant.example.lan',\
 admin_password => 'vagrant123',\
 directory_services_password => 'vagrant123',\
 install_ipa_server => true,\
 ip_address => '192.168.44.35',\
 enable_ip_address => true,\
 enable_hostname => true,\
 manage_host_entry => true,\
 install_epel => true,\
}"
SCRIPT

        box.vm.provision "shell", inline: $script
    end

    config.vm.define "vagrant-ipa2" do |box|
        box.vm.box = "bento/centos-7.3"
        box.vm.hostname = 'vagrant-ipa2.vagrant.example.lan'
        # Assign this VM to a host-only network IP, allowing you to access it
        # via the IP.
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 4096
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.36"

        $script = <<SCRIPT
echo I am provisioning...
export FACTER_is_vagrant='true'
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent
export PATH=$PATH:/opt/puppetlabs/bin
puppet module install puppetlabs-concat
puppet module install puppetlabs-stdlib
puppet module install crayfishx-firewalld
puppet module install puppet-selinux
if [ -d /tmp/modules/ipa ]; then rm -rf /tmp/modules/ipa; fi
mkdir -p /tmp/modules/ipa
cp -r /vagrant/* /tmp/modules/ipa
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  host {'vagrant-ipa1.example.lan':\
    ensure => present,\
    ip => '192.168.44.35',\
  }"
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "\
  class {'::ipa': \
    ipa_role => 'replica',\
    domain => 'vagrant.example.lan',\
    ipa_server_fqdn => 'vagrant-ipa2.vagrant.example.lan',\
    admin_password => 'vagrant123',\
    directory_services_password => 'vagrant123',\
    install_ipa_server => true,\
    ip_address => '192.168.44.36',\
    enable_ip_address => true,\
    enable_hostname => true,\
    manage_host_entry => true,\
    install_epel => true,\
    ipa_master_fqdn => 'vagrant-ipa1.vagrant.example.lan',\
  }"
SCRIPT

        box.vm.provision "shell", inline: $script
    end

end
