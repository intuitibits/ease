Vagrant.configure(2) do |config|
  config.vm.box = "debian/buster64"
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.vm.provider "virtualbox" do |vb|
    vb.name = "EASE"
    vb.memory = "256"
    vb.cpus = "1"
    vb.default_nic_type = "virtio"
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbxhci", "on"]
  end
  config.vm.provision :file, source: "ease.py", destination: "ease.py"
  config.vm.provision :file, source: "ease", destination: "ease"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  for i in 26700..26710
    config.vm.network "forwarded_port", guest: i, host: i
  end
  config.vm.post_up_message = "External Adapter Support Environment (EASE)"
end
