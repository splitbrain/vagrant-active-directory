# -*- mode: ruby -*-
# vi: set ft=ruby :

vmname = "dc"
hostname = "dc"
domain_fqdn = "example.local"
domain_netbios = "EXAMPLE"
domain_safemode_password = "Admin123#"

Vagrant.configure("2") do |config|
  config.vm.define "dc" do |cfg|
    cfg.vm.box = "gusztavvargadr/windows-server"
    cfg.vm.hostname = hostname

    # use the plaintext WinRM transport and force it to use basic authentication.
    # NB this is needed because the default negotiate transport stops working
    #    after the domain controller is installed.
    #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
    cfg.winrm.transport = :plaintext
    cfg.winrm.basic_auth_only = true

    cfg.vm.communicator = "winrm"
    # The private network IP is how RDP/LDAP/LDAPS are reached from the host.
    cfg.vm.network :private_network, ip: "192.168.56.5"

    # Upload scripts to C:\vagrant\scripts. Needed for libvirt where the
    # default synced folder is disabled. Redundant on VirtualBox (covered by
    # the synced folder) but cheap (<1s).
    cfg.vm.provision "file", source: "scripts", destination: "C:\\vagrant\\scripts"

    cfg.vm.provision "shell", path: "scripts/pre_ad.ps1", privileged: false
    cfg.vm.provision "shell", reboot: true
    cfg.vm.provision "shell", path: "scripts/mid_ad.ps1", privileged: false, args: "'#{hostname}' '#{domain_fqdn}' '#{domain_netbios}' '#{domain_safemode_password}'"
    cfg.vm.provision "shell", reboot: true
    cfg.vm.provision "shell", path: "scripts/post_ad.ps1", privileged: false, args: "'#{domain_fqdn}'"

    # Export the self-signed cert from the guest to the host repo root.
    # Works for both providers: with VirtualBox's synced folder the file is
    # already on the host, but downloading via WinRM keeps the libvirt path
    # working too without depending on synced folders.
    cfg.trigger.after :up, :reload do |trigger|
      trigger.name = "Export cert.der to host"
      trigger.ruby do |env, machine|
        guest_path = "C:\\vagrant\\cert.der"
        host_path = File.expand_path("cert.der", File.dirname(__FILE__))
        if machine.communicate.test("Test-Path '#{guest_path}'")
          machine.communicate.download(guest_path, host_path)
          machine.ui.success("Exported #{host_path}")
        end
      end
    end

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.name = vmname
      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", 4096]
      vb.customize ["modifyvm", :id, "--cpus", 2]
      vb.customize ["modifyvm", :id, "--vram", "16"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
      vb.customize ["modifyvm", :id, "--macaddress1", "auto"]
      vb.customize ["modifyvm", :id, "--macaddress2", "auto"]
      vb.customize ["modifyvm", :id, "--paravirtprovider", "hyperv"]
      vb.customize ["storagectl", :id, "--name", "SATA Controller", "--hostiocache", "on"]
    end

    cfg.vm.provider "libvirt" do |lv, override|
      lv.memory = 4096
      lv.cpus = 2
      lv.driver = "kvm"
      lv.disk_bus = "virtio"
      lv.nic_model_type = "virtio"
      lv.video_type = "vga"
      lv.graphics_type = "vnc"
      # Default synced folders on libvirt + Windows need extra setup (SMB/virtio-fs);
      # disable and rely on the top-level file provisioner instead.
      override.vm.synced_folder ".", "/vagrant", disabled: true
    end
  end
end
