#!/bin/bash

if [[ "$1" == "off" ]]; then
    printf "Clearing VPN DNS config from host..."
    sudo sh -c "grep -l -s \"#@OPENCONNECT_GATEWAY@\" /etc/resolver/* | xargs rm"
    echo done.
    printf "Removing VPN host routes..."
    VPN_ADDRESS_BLOCK=$(netstat -nr | grep -o "^\(\d\+\.\d\+\)\s\+\(10\.28\.28\.28\)"|cut -d" " -f 1)".0.0/16"
    sudo route -n delete -net $VPN_ADDRESS_BLOCK 10.28.28.28 > /dev/null 2>&1
    echo done.
elif [[ "$1" == "on" ]]; then
    # configure OSX to use the vpn name server for the domains below
    printf "Getting routing and DNS config from VM..."
    vagrant ssh --command "cp /etc/resolv.conf /vagrant/vpn-resolv.conf && printf \$(ip -f inet -o addr show tun0|cut -d\  -f 7 | cut -d/ -f 1 | cut -d. -f 1,2).0.0/16 > /vagrant/vpn-address-block.txt" > /dev/null 2>&1
    echo done.

    printf "Configuring host routes..."
    # configure host to route the vpn address block requests through the vpn vm
    VPN_ADDRESS_BLOCK=$(cat vpn-address-block.txt)
    sudo route -n add -net $VPN_ADDRESS_BLOCK 10.28.28.28 > /dev/null 2>&1
    echo done.

    # Configure DNS
    echo Configuring host DNS...
    RESOLV_DOMAINS=($(cat vpn-resolv.conf | grep "domain\|search"|cut -d" " -f 2))
    if [ -f other-domains.txt ]
    then
        CUSTOM_DOMAINS=($(cat other-domains.txt | tr "\n" " "))
    else
        CUSTOM_DOMAINS=()
    fi

    DOMAINS=("${RESOLV_DOMAINS[@]}" "${CUSTOM_DOMAINS[@]}")
    NAMESERVERS=$(cat vpn-resolv.conf | grep nameserver)

    sudo mkdir -p /etc/resolver
    for domain in "${DOMAINS[@]}"
    do
        echo "Setting DNS servers for ${domain}"
        sudo rm -rf /etc/resolver/$domain
        sudo sh -c "echo \"#@OPENCONNECT_GATEWAY@\n$NAMESERVERS\" > /etc/resolver/$domain"
    done
    echo Configuring host DNS...done.

else
    echo "Use: networking-config.sh <on|off>"
fi

