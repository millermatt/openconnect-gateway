#!/bin/sh

showUse () {
    echo "Use: connect.sh --user=mario --group=vpnusers vpn.mycompany.com"
    exit 1
}

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    shift # past argument=value
    ;;
    -g=*|--group=*)
    GROUP="${i#*=}"
    shift # past argument=value
    ;;
    -s=*|--server=*)
    SERVER="${i#*=}"
    shift # past argument=value
    ;;
    -h*|--help*)
    showUse
    shift
    ;;
    --default)
    shift # past argument with no value
    ;;
    *)
    ;;
esac
done
SERVER=$1
echo "USER      = ${USER}"
echo "AUTHGROUP = ${GROUP}"
echo "SERVER    = ${SERVER}"

# Create and/or launch the VM
vagrant up

# launch the vpn connection
vagrant ssh -- -t "LC_VPN_SERVER=$SERVER LC_VPN_GROUP=$GROUP LC_VPN_USER=$USER sudo -E /vagrant/vpn.sh"


