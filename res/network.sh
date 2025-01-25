NETPLAN_CONFIG="/etc/netplan/99-config.yaml"
MATCH_PATTERN="en*"    # Matches typical systemd interface names (e.g. enp1s0)


# 1. Install netplan if missing
if ! command -v netplan >/dev/null 2>&1; then
  echo "Installing netplan.io"
  sudo apt-get install -y netplan.io

  # Disable the old ifupdown (Debian) config if it exists
  if [ -f /etc/network/interfaces ]; then
    echo "Backup existing /etc/network/interfaces -> .backup"
    sudo mv /etc/network/interfaces /etc/network/interfaces.backup.$(date +%Y%m%d%H%M%S)
  fi
fi

echo "Interfaces matching: \"$MATCH_PATTERN\""
echo -e "${GREEN}Press Enter to use DHCP, or type a static IP in CIDR (e.g. 192.168.1.100/24)${ENDCOLOR}"
read -r -p "Static IP [blank for DHCP]: " STATIC_IP

if [ -z "$STATIC_IP" ]; then
  echo "Configuring DHCP on all interfaces matching '$MATCH_PATTERN'..."
  sudo tee "$NETPLAN_CONFIG" >/dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    all_en_interfaces:
      match:
        name: "$MATCH_PATTERN"
      dhcp4: true
EOF

else
  echo "Configuring static IP: $STATIC_IP"
  read -r -p "Gateway IP (e.g. 192.168.1.1): " GATEWAY_IP
  DNS_IPS="1.1.1.1,9.9.9.9"
  DNS_SPACED="${DNS_IPS//,/ }"

  sudo tee "$NETPLAN_CONFIG" >/dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    all_en_interfaces:
      match:
        name: "$MATCH_PATTERN"
      addresses:
        - $STATIC_IP
      gateway4: $GATEWAY_IP
      nameservers:
        addresses: [$DNS_IPS]
EOF
fi

echo -e "${GREEN}Netplan config saved to: $NETPLAN_CONFIG (restart required to apply)${ENDCOLOR}"

