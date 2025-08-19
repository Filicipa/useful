# WireGuard
## Install
```bash
sudo apt update
sudo apt install wireguard -y
```
### Generate server keys
```bash
cd /etc/wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```
### Create client config keys
```bash
cd /etc/wireguard
export CLIENT=<client_name>
wg genkey | tee $CLIENT"_private.key" | wg pubkey > $CLIENT"_public.key"
```
### Create server config file `wg0.conf`
```ini
[Interface]
# Internal IP-server WireGuard
Address = 10.0.0.1/24
# Server private key
PrivateKey = ****
ListenPort = 51820

PostUp = sysctl -w net.ipv4.ip_forward=1; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = sysctl -w net.ipv4.ip_forward=0; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client 1
[Peer]
PublicKey = ****
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 5

# Client 2
[Peer]
PublicKey = ****
AllowedIPs = 10.0.0.3/32
PersistentKeepalive = 5
```
### Reload wireguard
```bash
wg-quick down wg0
wg-quick up wg0
wg show
```

### Create user config file
```ini
[Interface]
# User private key
PrivateKey = 
Address = 10.0.0.5/24

[Peer]
# Server public key
PublicKey = 
AllowedIPs = <server_ip>/32, 10.0.0.1/32, 10.0.0.0/24
Endpoint = <server_ip>:51820
PersistentKeepalive = 5
```

Script example
```bash
#!/bin/bash
set -e

GREEN='\e[32m'
RED='\e[31m'
NC='\e[0m' # No Color

read -r -p "Enter file name (e.g. client3): " CLIENT

NUM=$(echo "$CLIENT" | grep -o '[0-9]\+' || true)

if [[ -z "$NUM" ]]; then
  echo -e "${RED} Error: couldn't extract number from '$CLIENT'. The name must contain digits${NC}"
  exit 1
fi

if [[ -f "${CLIENT}_publickey" ]]; then
  echo -e "${RED} Error: file '${CLIENT}_public.key' already exists.${NC}"
  exit 1
fi

wg genkey | tee "$CLIENT""_private.key" | wg pubkey > "$CLIENT""_public.key"

KEY=$(cat "${CLIENT}_public.key")
IP="10.0.0.$NUM/32"

cat <<EOF >> wg0.conf

# $CLIENT
[Peer]
PublicKey = ${KEY}
AllowedIPs = ${IP}
EOF

echo -e "${GREEN} Configuration for $CLIENT added with IP $IP${NC}"

```