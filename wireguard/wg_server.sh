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
  echo -e "${RED} Error: file '${CLIENT}_publickey' already exists.${NC}"
  exit 1
fi

wg genkey | tee "$CLIENT""_privatekey" | wg pubkey > "$CLIENT""_publickey"

KEY=$(cat "${CLIENT}_publickey")
IP="10.0.0.$NUM/32"

cat <<EOF >> wg0.conf

# $CLIENT
[Peer]
PublicKey = ${KEY}
AllowedIPs = ${IP}
EOF

echo -e "${GREEN} Configuration for $CLIENT added with IP $IP${NC}"