#!/bin/bash

echo server: $LC_VPN_SERVER
echo group:  $LC_VPN_GROUP
echo user:   $LC_VPN_USER

function sysctl_set() {
    key=$1
    value=$2
    config_path='/etc/sysctl.conf'
    # set now
    sysctl -w ${key}=${value}
    # persist on reboot
    if grep -q "${key}" "${config_path}"; then
        sed -i "s/#${key}/${key}/g" "${config_path}"
        sed -i "s/^${key}.*$/${key} = ${value}/" "${config_path}"
    else
        echo "${key} = ${value}" >> "${config_path}"
    fi
}

# allow ip forwarding from the host
sysctl_set net.ipv4.ip_forward 1
iptables -A FORWARD -o tun0 -i eth1 -s 10.28.28.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

openconnect \
    -v \
    --csd-wrapper /vagrant/csd-wrapper.sh \
    --csd-user vagrant \
    --authgroup $LC_VPN_GROUP \
    -u $LC_VPN_USER \
    $LC_VPN_SERVER
