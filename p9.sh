#!/bin/bash

# Pro9: Unleash your ideas privately.
# Connect to a Japanese or Chinese WireGuard VPN using a GUI selector.

# Check WireGuard installation
if ! command -v wg-quick >/dev/null 2>&1; then
  yad --error --text="WireGuard (wg-quick) not found. Please install before running this script."
  exit 1
fi

# YAD: Country selection
COUNTRY=$(yad --center --width=350 --height=200 \
  --title="Pro9: Unleash your ideas privately." \
  --form \
  --field="Choose Country:CB" "Japan!China" \
  --text="Select a VPN endpoint country")

if [[ -z "$COUNTRY" ]]; then
  yad --info --text="No country selected. Exiting."
  exit 1
fi

CHOICE=$(echo "$COUNTRY" | cut -d'|' -f1)
SHOWNAME="$CHOICE"

# Prompt user for WireGuard config details
FORM=$(yad --form --center --width=400 --height=300 \
  --title="Enter $SHOWNAME WireGuard Config" \
  --field="Private Key":H \
  --field="Address" \
  --field="DNS" \
  --field="Peer Public Key" \
  --field="Endpoint" \
  --field="Allowed IPs" \
  --text="Enter WireGuard configuration details for $SHOWNAME:")

if [[ -z "$FORM" ]]; then
  yad --info --text="No config entered. Exiting."
  exit 1
fi

IFS="|" read -r PRIVATE_KEY ADDRESS DNS PEER_PUBKEY ENDPOINT ALLOWED_IPS <<< "$FORM"

TMP_CONF=$(mktemp)
chmod 600 "$TMP_CONF"
cat > "$TMP_CONF" <<EOL
[Interface]
PrivateKey = $PRIVATE_KEY
Address = $ADDRESS
DNS = $DNS

[Peer]
PublicKey = $PEER_PUBKEY
Endpoint = $ENDPOINT
AllowedIPs = $ALLOWED_IPS
EOL

# Confirm and connect
yad --question --title="Pro9: $SHOWNAME VPN" --text="Connect to $SHOWNAME VPN?\n\nTagline:\n<b>Unleash your ideas privately.</b>"
if [[ $? -eq 0 ]]; then
  # Try to disconnect any existing wg connection
  sudo wg-quick down "$TMP_CONF" 2>/dev/null
  # Bring up selected connection
  if sudo wg-quick up "$TMP_CONF"; then
    yad --info --text="Connected to $SHOWNAME VPN!\n\nYour IP should now be $SHOWNAME."
  else
    yad --error --text="Failed to connect to $SHOWNAME VPN."
  fi
else
  yad --info --text="Cancelled."
fi

# Clean up
sudo wg-quick down "$TMP_CONF" 2>/dev/null
rm -f "$TMP_CONF"
exit 0
