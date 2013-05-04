# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "raring64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/raring/current/raring-server-cloudimg-vagrant-amd64-disk1.box" 

  config.vm.provision :chef_solo do |chef|
    chef.run_list = ["recipe[docker-play::default]"]
  end

  config.berkshelf.enabled = true
  config.vm.synced_folder "src/", "/home/vagrant/src"
end
