
Vagrant.configure("2") do |config|
  config.vm.box = "minimal/jessie64"
  config.vm.box_version = "8.0"

  config.vm.provider "virtualbox" do |p|
    p.name = "vpn"
    p.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  end

  # The VM will have a static IP of 10.28.28.28
  config.vm.network "private_network", ip: "10.28.28.28"

  config.vm.hostname = "vpn"
  config.vm.post_up_message = "usage instructions: see the README.txt file"

  config.vm.provision "shell", inline: <<SCRIPT
    date > /etc/vagrant_provisioned_at
    apt-get update
    apt-get install -y ca-certificates openconnect wget
SCRIPT

end