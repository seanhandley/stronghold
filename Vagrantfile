# -*- mode: ruby -*-
# vi: set ft=ruby :

# Ensure everyone is running a consistent vagrant version
Vagrant.require_version '~> 1.7.2'

Vagrant.configure('2') do |config|
  config.vm.box              = 'seanhandley/dc_rails'
  config.vm.box_version      = '1.0.1'
  config.vm.box_check_update = true

  # Give every guest private networking
  config.vm.network :private_network, type: :dhcp

  # Use landrush for DNS resolution
  config.landrush.enabled = true
  config.landrush.tld = 'vagrant.devel'

  config.vm.hostname = "stronghold.vagrant.devel"

  config.vm.network 'forwarded_port', guest: 8080,
                                      host: 8080,
                                      protocol: 'tcp'

  # Virtualbox Provider
  config.vm.provider 'virtualbox' do |virtualbox, override|
    virtualbox.cpus   = 2
    virtualbox.memory = 2000
    virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync"

end
