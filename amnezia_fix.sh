#!/bin/bash
set -euo pipefail
DOMAIN="gw.amnezia.org"
#echo -n "WLAN AP name: "; read -r WLAN_IP

#Perform basic network check
echo "Setting default gateway..."
DEFAULT_GW=$(ip -c=never route show default | awk '{print $3}' | head -n1)
if [[ -z "$DEFAULT_GW" ]]; then
    echo "No default gateway found. Are you connected to LAN?" >&2
    exit 1
fi

echo "Pinging default GW..."
ping -c 3 -W 3 "$DEFAULT_GW" || { echo "GW unreachable. Are you connected to LAN?" >&2; exit 1; }
echo "Pinging Google DNS..."
ping -c 3 -W 3 8.8.8.8 || { echo "Google DNS does not respond" >&2; exit 1; }

#Resolve domain and get up to 2 IPs
echo "Resolving domains..."
mapfile -t IP_ADDRESSES < <(dig +short "$DOMAIN" | tail -n 2)

if [[ ${#IP_ADDRESSES[@]} -eq 0 ]]; then
    echo "Failed to resolve $DOMAIN" >&2
    exit 1
fi

echo "Writing changes to /etc/hosts file..."
if [[ -f /etc/hosts ]]; then
    if [[ ! -w /etc/hosts ]]; then
	echo "/etc/hosts is not writable. Run as root?" >&2
	exit 1
    fi

    #Remove existing lines
    sed -i "/${DOMAIN}/d" /etc/hosts

    #Add new entries
    for ip in "${IP_ADDRESSES[@]}"; do
	if [[ -n "$ip" ]]; then
	    printf "%s\t%s\n" "$ip" "$DOMAIN" >> /etc/hosts
	fi
    done
fi

#Restart wireless and DNS services
echo "Restarting services..."
iwctl station wlan0 disconnect
ip link set wlan0 down
systemctl restart systemd-resolved.service
resolvectl flush-caches
ip link set wlan0 up
#iwctl station wlan0 connect $WLAN_IP

echo "You are good to go!"
exit 0
