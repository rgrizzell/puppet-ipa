# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

    config.vm.define "ipa-server-1" do |box|
        box.vm.box = "centos/7"
        box.vm.box_version = "1901.01"
        box.vm.hostname = 'ipa-server-1.vagrant.example.lan'
        # Assign this VM to a host-only network IP, allowing you to access it
        # via the IP.
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1536
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.35"
        box.vm.network "forwarded_port", guest: 8000, host: 8000
        box.vm.network "forwarded_port", guest: 8440, host: 8440
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/centos-7-disable-nm.sh"
        box.vm.provision "shell", path: "vagrant/ipa-server-1.sh"
    end

    config.vm.define "ipa-server-2" do |box|
        box.vm.box = "centos/7"
        box.vm.box_version = "1901.01"
        box.vm.hostname = 'ipa-server-2.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1536
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.36"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/centos-7-disable-nm.sh"
        box.vm.provision "shell", path: "vagrant/ipa-server-2.sh"
    end

    config.vm.define "ipa-client-1" do |box|
        box.vm.box = "centos/7"
        box.vm.box_version = "1901.01"
        box.vm.hostname = 'ipa-client-1.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.37"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/centos-7-disable-nm.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client-1.sh"
    end

    config.vm.define "ipa-client-2" do |box|
        box.vm.box = "ubuntu/xenial64"
        box.vm.box_version = "20171118.0.0"
        box.vm.hostname = 'ipa-client-2.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.38"
        box.vm.provision "shell" do |s|
          s.path = "vagrant/debian.sh"
          s.args = ["xenial"]
        end
        box.vm.provision "shell", path: "vagrant/ipa-client-1.sh"
    end

    config.vm.define "ipa-client-3" do |box|
        box.vm.box = "ubuntu/trusty64"
        box.vm.box_version = "20171205.0.1"
        box.vm.hostname = 'ipa-client-3.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.39"
        box.vm.provision "shell" do |s|
          s.path = "vagrant/debian.sh"
          s.args = ["trusty"]
        end
        box.vm.provision "shell", path: "vagrant/ipa-client-1.sh"
    end

    config.vm.define "ipa-client-4" do |box|
        box.vm.box = "debian/stretch64"
        box.vm.box_version = "9.3.0"
        box.vm.hostname = 'ipa-client-4.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.44.40"
        box.vm.provision "shell" do |s|
          s.path = "vagrant/debian.sh"
          s.args = ["stretch"]
        end
        box.vm.provision "shell", path: "vagrant/ipa-client-1.sh"
    end
end
