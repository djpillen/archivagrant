# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "hashicorp/precise32"

  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8089, host: 8089


  config.vm.provider "virtualbox" do |vb|
     vb.memory = "2048"
  end

  config.vm.provision "shell", path:"setup_python.sh"
  config.vm.provision "shell", path:"install_mysql.sh"
  config.vm.provision "shell", path:"setup_archivesspace.sh"
end
