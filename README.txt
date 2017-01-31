
== Connect to a VPN without routing everything through the VPN ==

TL;DR
# Connect to vpn
./connect.sh --user=vpnuser --group=vpngroup vpnserver.mycompany.com
    - If you get 2 password prompts then enter your generated RSA token at the second password prompt.
# Route vpn network traffic through vm
./networking-config.sh


First time setup
================
Install Vagrant: https://www.vagrantup.com/docs/installation/
Install VirtualBox and the Virtual Box Extension Pack (same page): https://www.virtualbox.org/wiki/Downloads


To connect
==========
1) Open a terminal and cd to the folder this README.txt file is in.

2) Connect the VM to the vpn: 
    $ ./connect.sh (-u|-user)=vpnuser (-g|--group)=vpngroup vpn.mycompany.com
    Notes:
    - If you receive USB 2.0 or Oracle VM Virtual box error:
        - Open the VirtualBox Application and navigate to Settings -> Ports - USB.
        - Uncheck the “Enable USB Controller” checkbox which is checked by default.	
        - This generally should not be necessary if you have the Virtual Box Extension Pack, but it depends on the VirtualBox configuration
    - It may prompt you twice for a password. The first one is your vpn password. The second one is your generated RSA token.
    - The the first time you run this it will download a number of files so it takes a minute or two.
    - After connecting the vpn connection will be running in the foreground of the terminal and show "keep alive" messages and "handshake failed" messages. You can ignore them.
    - Hit CTRL+C to end the vpn connection

3) Open a second terminal and cd to this folder

4) Configure host networking to route appropriate traffic through the VM:
    $ ./networking-config.sh on
    Notes:
    - This must be run after connecting to the vpn so that the address block is available.
    - It will probably prompt you for your local password so that it can use sudo to configure routing


To disconnect
=============
1) CTRL+C in the running VPN terminal

2) Optionally reset networking:
    $ ./networking-config.sh off
    - It will probably prompt you for your local password so that it can use sudo to configure routing

Files
=====
connect.sh              - Runs in host OS.  Starts the VPN connection inside the VM.
csd-wrapper.sh          - Runs in VM.       Used by the VPN connection software to handle VPN server commands.
networking-config.sh    - Runs in host OS.  Configures host networking to send appropriate traffic through the VM.
Vagrantfile             - Runs in host OS.  Config file for Vagrant to create the VM
vpn.sh                  - Runs in VM.       Called by connect.sh. Starts the VPN connection.


FAQ
===
Q: Why isn't DNS working?
A: That's on the todo list. You can access servers by IP or add entries to your hosts file for known hosts. Running ./networking-config.sh will copy the resolv.conf file (as vpn-resolv.conf) from the vm to the same folder this readme file is in. You can copy that to the right places on the hosts system or extract the info from it and use it. I don't have an example of this yet.

Q: Why Vagrant/VirtualBox and not Docker?
A: It can't be done with Docker on OSX due to limitations of Hyperkit. There is no way to directly access the docker "vm" from the host on OSX without going through specific ports. Port access happens at a higher level than we need to be to enable the proper routing. See "Known Limitations" at https://docs.docker.com/docker-for-mac/networking/

Q: How do I open a terminal inside the VM?
A: From the folder this README.txt file is in: $ vagrant ssh

Q: What if nothing seems to happen for a while after the VM boots up, and then I get the message "ssh_exchange_identification: Connection closed by remote host"?
A: Try again

Q: My host resumed from sleep and now everything is frozen. What now?
A: Use the Virtual Box Manager to shut down the VM and then run ./connect.sh again.

Q: Should I worry about "DTLS handshake timed out" and "DTLS handshake failed: Resource temporarily unavailable, try again." messages?
A: Nope

