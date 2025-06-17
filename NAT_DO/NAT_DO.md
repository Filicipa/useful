[Setup NET server on digital ocean](https://https://docs.digitalocean.com/products/networking/vpc/how-to/configure-droplet-as-gateway/)

Create a '/etc/sysctl.d/99-ipv.conf' with the following lines:
```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```
Then run:
```bash
sudo systemctl restart  procps
sudo sysctl -p
```
### Check
```bash
curl icanhazip.com
```
## Bash script
```bash
#!/bin/bash
set -e
VPC_CIDR="10.0.0.0/16"

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-nat-gateway.conf
sysctl --system

iptables -t nat -A POSTROUTING -s $VPC_CIDR -o eth0 -j MASQUERADE

apt-get update -y
apt-get install -y iptables-persistent

iptables-save > /etc/iptables/rules.v4
```
