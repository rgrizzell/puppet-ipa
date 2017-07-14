# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

    config.vm.define "vagrant-ipa" do |vm|
        config.vm.box = "bento/centos-7.3"
        config.vm.hostname = 'vagrant-ipa1.example.lan'
        # Assign this VM to a host-only network IP, allowing you to access it
        # via the IP.
        config.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 4096
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        config.vm.network "public_network", ip: "192.168.44.35"

        # Second network interface, vm's will all exist on this network
        vm.network "public_network", ip: "192.168.44.35"

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
 domain => 'vagrant.ipa.explorys.net',\
 realm => 'vagrant.ipa.explorys.net',\
 ipa_server_fqdn => 'vagrant-ipa.example.lan',\
 admin_password => 'vagrant123',\
 directory_services_password => 'vagrant123',\
 install_ipa_server => true,\
 ip_address => '192.168.44.35',\
 enable_ip_address => true,\
 enable_hostname => true,\
 manage_host_entry => true,\
 install_epel => true,\
 replica_fqdn_list => ['vagrant-ipa2.example.lan'],\
}"
SCRIPT

        config.vm.provision "shell", inline: $script
    end

    config.vm.define "vagrant-ipa2" do |vm|
        vm.box = "bento/centos-7.3"
        vm.hostname = 'vagrant-ipa2.example.lan'
        # Assign this VM to a host-only network IP, allowing you to access it
        # via the IP.
        vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 4096
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        vm.network "public_network", ip: "192.168.44.36"

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
 ipa_role => 'replica',\
 domain => 'vagrant.ipa.explorys.net',\
 ipa_server_fqdn => 'vagrant-ipa2.example.lan',\
 admin_password => 'vagrant123',\
 directory_services_password => 'vagrant123',\
 install_ipa_server => true,\
 ip_address => '192.168.44.36',\
 enable_ip_address => true,\
 enable_hostname => true,\
 manage_host_entry => true,\
 install_epel => true,\
}"
SCRIPT

        config.vm.provision "shell", inline: $script
    end

end
