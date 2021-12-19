# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variables
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

CONTROLLER = ENV.fetch('CONTROLLER1', 'VirtIO')
ST_DIR = "extradisks/"
DISK1_SIZE = 10240

PLAYBOOK_DIR = "/vagrant/ansible"
ROLES_DIR = "/vagrant/ansible/roles"
ANSIBLE_INVENTORY = "#{PLAYBOOK_DIR}" + '/inventory/hosts'

IMAGE_NAME  = "generic/ubuntu2004"

lab = {
  "k8s-00"    => { :osimage => IMAGE_NAME, :ip => "192.168.56.10",   :cpus => 2, :mem =>2048, :custom_host => "k8s-00.sh"    },
  "k8s-01"    => { :osimage => IMAGE_NAME, :ip => "192.168.56.11",   :cpus => 2, :mem =>2048, :custom_host => "k8s-01.sh"    },
  "k8s-02"    => { :osimage => IMAGE_NAME, :ip => "192.168.56.12",   :cpus => 2, :mem =>2048, :custom_host => "k8s-02.sh"    },
  "k8s-03"    => { :osimage => IMAGE_NAME, :ip => "192.168.56.13",   :cpus => 2, :mem =>2048, :custom_host => "k8s-03.sh"    },
  "infra-00"  => { :osimage => IMAGE_NAME, :ip => "192.168.56.20",   :cpus => 2, :mem =>2048, :custom_host => "infra-00.sh"  },
  "infra-01"  => { :osimage => IMAGE_NAME, :ip => "192.168.56.21",   :cpus => 2, :mem =>2048, :custom_host => "infra-01.sh"  },
  "infra-02"  => { :osimage => IMAGE_NAME, :ip => "192.168.56.22",   :cpus => 2, :mem =>2048, :custom_host => "infra-02.sh"  },
  "installer" => { :osimage => IMAGE_NAME, :ip => "192.168.56.100",  :cpus => 1, :mem =>1024, :custom_host => "installer.sh" }
  }

Vagrant.configure("2") do |config|
  lab.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|

      # Synchronization apps/ dir into destination /vagrant dir (needed for deploy application into K8s cluster)
      config.vm.synced_folder '.', '/vagrant',
      type: 'rsync',
      # rsync__verbose: true,
      rsync__exclude: [
        'extrastorage', 'src', '.gitignore',
        'README.md', 'Vagrantfile', '.vagrant', 
        '.git',
      ]

      # Allow login ssh use password also
      cfg.vm.provision "shell", inline: "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;systemctl restart sshd", privileged: true

      # Define motd
      cfg.vm.provision "shell", path: "src/scripts/provisioning/#{info[:custom_host]}", privileged: true


      if (hostname == 'installer') then
        # Prerequisite ansible playbooks for kubernetes
        cfg.vm.provision "ansible_local" do |ansible|
            ansible.verbose = "v"
            ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'installer-prereq.yaml'
            ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # Kubernetes end ansible playbook runs
      end

      if (hostname == 'k8s-01') or (hostname == 'k8s-02') or (hostname == 'k8s-03') then

        cfg.vm.provider :virtualbox do |vb, override|

          # Add VirtIO controller
          vb.customize ["storagectl", :id, "--name", CONTROLLER, "--add", "virtio-scsi" ]
       
          # Adding extra disk to all worker nodes
          file_disk1 = ST_DIR + hostname + '_disk1.vdi'
          file_disk2 = ST_DIR + hostname + '_disk2.vdi'

          unless File.exist?(file_disk1)
            vb.customize ['createhd', '--filename', file_disk1, '--size', "#{DISK1_SIZE}"]
          end
         
          # Attach disk to vm
          vb.customize ['storageattach', :id, '--storagectl', CONTROLLER, '--port', 0, '--device', 0, '--type', 'hdd', '--medium', file_disk1 ]

        end # end provider
      end # end if

      # Prepare /etc/hosts adopt entries interconnect cluster
      cfg.vm.provision "ansible_local" do |ansible|
        ansible.verbose = true
        ansible.install = true
        ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'sync-hosts.yaml'
        ansible.galaxy_roles_path = "#{ROLES_DIR}"
      end # end hosts file preparation

      # start first run privider
      cfg.vm.provider :virtualbox do |vb, override|

        # Memory, CPU, Image configuration
        vb.memory = "#{info[:mem]}"
        vb.cpus = "#{info[:cpus]}"
        config.vm.box = info[:osimage]

        override.vm.network :private_network, ip: "#{info[:ip]}"

        # Configure hostname
        override.vm.hostname = hostname

      end # end provider
    end # end config
  end # end lab
end
