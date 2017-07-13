# -*- mode: ruby -*-

Vagrant.configure("2") do |config|
    # Every Vagrant virtual environment requires a box to build off of.
    #config.vm.box = "puppetlabs/centos-7.2-64-puppet"

    config.vm.box = "bento/centos-7.3"
    # Assign this VM to a host-only network IP, allowing you to access it
    # via the IP.
    config.vm.provider 'virtualbox' do |vb|
        vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
        vb.gui = false
        vb.memory = 4096
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--hpet", "on"]
    end

    # Second network interface, vm's will all exist on this network
    ip = "192.168.44.35"
    config.vm.network :private_network, ip: ip
#    config.vm.network :forwarded_port, guest: 9300, host: 9393

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
puppet apply --modulepath '/tmp/modules:/etc/puppetlabs/code/environments/production/modules' -e "class {'::ipa': ipa_role => 'server', domain => 'vagrant.ipa.explorys.net', realm => 'vagrant.ipa.explorys.net', admin_password => 'vagrant', directory_services_password => 'vagrant', install_ipa_server => true,}"
SCRIPT

    config.vm.provision "shell", inline: $script

end
