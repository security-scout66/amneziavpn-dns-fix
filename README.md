# amneziavpn-dns-fix
A bash script for solving AmneziaVPN (4.8.10.0) 1103/1104 errors

The process of solving 1103/1104 errors is as follows:
1. Connect to the internet if you haven't already
2. Run the script
3. Start AmneziaVPN client and try to connect to a proxy server. You can tweak options such as using VLESS protocol or AmneziaDNS, as well as choosing other server locations

If script encounters any connectivity issues, such as inaccessible default GW (your router), external IP addresses or DNS servers, it will print an error message.

WARNING: hardcoded network interface wlan0, interface name can be different on other systems. If the interface you are using to access internet has a different name, modify the script accorfingly
