# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

# Read environment for surface file.
surface = "#{ENV["VAGRANT_SURFACE"]}"


# Load surface
fn = File.dirname(File.expand_path(__FILE__))
if "#{surface}" == ""
  fn = fn + '/surface.yaml'
else
  fn = fn + "/#{surface}"
end
puts "Loading surface file: #{fn}"
cnf = YAML::load(File.open(fn))

SURFACE_SEED = cnf

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if SURFACE_SEED["cache-deb"]
    if Vagrant.has_plugin?("vagrant-cachier")
      config.cache.scope = :box
    else
      puts 'NOTICE: Install vagrant-cachier to take advantage of caching deb files:'
      puts '    vagrant plugin install vagrant-cachier'
    end
  end

  if SURFACE_SEED["persistent-storage-enabled"]
    if not Vagrant.has_plugin?("vagrant-persistent-storage")
      puts 'NOTICE: Install vagrant-persistent-storage to support drives for storage nodes.'
      puts '  vagrant plugin install vagrant-persistent-storage'
      exit()
    end
  end

  if SURFACE_SEED["base-box"]
    config.vm.box = SURFACE_SEED["base-box"]
  else
    config.vm.box = "hashicorp/precise64"
  end

  SURFACE_SEED["machines"].each do |node_name, node_data|
    config.vm.define node_name do |vm_config|
      vm_config.vm.hostname = "#{node_name}.local.dev"
      if node_data["box"]
        vm_config.box = node_data["box"]
      end

      if node_data["interfaces"]
        node_data["interfaces"].to_enum.with_index(1).each do |(int_name, int_data), i|
          if "#{int_name}" == "external"
            vm_config.vm.network "private_network", auto_config: int_data["auto_config"], ip: "#{int_data['network']}", mac: int_data["mac"].tr(':', '').upcase
          elsif "#{int_name}" == "external_dhcp"
            vm_config.vm.network "private_network", auto_config: int_data["auto_config"], type: "dhcp", mac: int_data["mac"].tr(':', '').upcase
          elsif "#{int_name}" == "public"
            vm_config.vm.network "public_network"
          else
            vm_config.vm.network "private_network", auto_config: int_data["auto_config"], type: "dhcp", mac: int_data["mac"].tr(':', '').upcase, virtualbox__intnet: "#{int_name}"
          end
        end
      end

      if node_data["ports"]
        node_data["ports"].to_enum.with_index(1).each do |(port_name, port_data), i|
          if port_data
            vm_config.vm.network "forwarded_port", guest: port_data["guest"], host: port_data["host"] if port_data["guest"] && port_data["host"]
          end
        end
      end

      if node_data["avahi"]
        vm_config.vm.provision "shell", inline: <<-SHELL
          apt-get install -yq avahi-daemon
        SHELL
      end

      if node_data["salt"]
        node_salt = node_data["salt"]
        local_salt_path = node_salt["local-salt-path"] || "./salt"
        server_salt_path = node_salt["server-salt-path"] || "/srv/salt"
        vm_config.vm.synced_folder local_salt_path, server_salt_path
        # clear the minion id so that it gets recreated based on hostname above.
        # vm_config.vm.provision "shell", inline: "rm -f /etc/salt/minion_id; service salt-minion restart"

        vm_config.vm.provision :salt do |salt|
          salt.install_type = "stable"
          salt.minion_config = node_salt["minion-config"] || "./minion.conf"
          salt.run_highstate = node_salt["run-highstate"] || false
          salt.colorize = true
          salt.verbose = true
        end
      end

      if node_data["docker"]
        vm_config.vm.provision "docker" do |d|
          node_data["docker"].to_enum.with_index(1).each do |(name, data), i|
            if data["run"]
              d.run "#{name}", image: "#{data['image']}", args: "#{data['args']}", cmd: "#{data['command']}"
            else
              d.pull_images "#{data['image']}"
            end
          end
        end
      end

      vm_config.vm.provider "virtualbox" do |v|
        v.gui = false
        v.customize ["modifyvm", :id, "--memory", node_data["memory"]] if node_data["memory"]
        v.customize ["modifyvm", :id, "--cpus", node_data["cpus"]] if node_data["cpus"]

        if node_data['persistent-storage']
          node_storage = node_data['persistent-storage']
          vm_config.persistent_storage.enabled = true
          vm_config.persistent_storage.use_lvm = false
          # vm_config.persistent_storage.format = false
          vm_config.persistent_storage.location = node_storage['disk-path'] || "#{node_name}-storage-volume.vdi"
          vm_config.persistent_storage.size = node_storage['disk-size'] || 20000
          vm_config.persistent_storage.mountname = 'sdb1' # this must be sdb1 for a non-LVM disk on default device.
          vm_config.persistent_storage.filesystem = 'ext4'
          vm_config.persistent_storage.mountpoint = node_storage['mount-point'] || "/mnt/storage"
          # vm_config.persistent_storage.volgroupname = 'myvolgroup'
        end
      end
    end
  end
end
