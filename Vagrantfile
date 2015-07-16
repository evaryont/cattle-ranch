# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.7"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'chef/debian-7.8'

  config.vm.provider "virtualbox" do |vb|
    #vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.hostname = "clockwerk.dev"

  config.vm.provision "chef_client" do |chef|
    chef.chef_server_url     = "https://api.opscode.com/organizations/evaryont"
    chef.validation_key_path = "~/.chef/evaryont-validator.pem"
    chef.validation_client_name = "evaryont-validator"
    chef.delete_node = true
    chef.delete_client = true
    chef.version = '12.3.0'

    chef.run_list << "recipe[mailbag]"
    chef.json = {
    }
  end
end
