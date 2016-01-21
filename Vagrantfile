# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'hubotps'

  config.vm.synced_folder '.', 'C:/PROGRA~1/WindowsPowerShell/Modules/Hubot-PowerShell'

  config.vm.box = 'kensykora/windows_2012_r2_standard'

  config.vm.network :private_network, type: 'dhcp'

  config.vm.provider 'virtualbox' do |v|
    v.gui = true
    v.cpus = 2
    v.memory = 2048
  end
end
