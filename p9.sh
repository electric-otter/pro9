#!/bin/bash

# Pro9: Unleash your ideas privately.
# Connect to a Japanese or Chinese WireGuard VPN using a GUI selector.

WG_CONF_DIR="$HOME/wireguard-configs"   # Directory containing WireGuard .conf files
JAPAN_CONF="japan.conf"
CHINA_CONF="china.conf"

# Check WireGuard installation
if ! command -v wg-quick >/dev/null 2>&1; then
  yad --error --text="WireGuard (wg-quick) not found. Please install before running this script."
  exit 1
fi

# Check config files
if [[ ! -f "$WG_CONF_DIR/$JAPAN_CONF" || ! -f "$WG_CONF_DIR/$CHINA_CONF" ]]; then
  yad --error --text="Missing $JAPAN_CONF or $CHINA_CONF in $WG_CONF_DIR. Add your .conf files for Japan and China."
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

if [[ "$CHOICE" == "Japan" ]]; then
  CONF="$JAPAN_CONF"
  SHOWNAME="Japanese"
elif [[ "$CHOICE" == "China" ]]; then
  CONF="$CHINA_CONF"
  SHOWNAME="Chinese"
else
  yad --error --text="Invalid selection."
  exit 1
fi

# Confirm and connect
yad --question --title="Pro9: $SHOWNAME VPN" --text="Connect to $SHOWNAME VPN?\n\nTagline:\n<b>Unleash your ideas privately.</b>"
if [[ $? -eq 0 ]]; then
  # Try to disconnect any existing wg connection
  sudo wg-quick down "$WG_CONF_DIR/$JAPAN_CONF" 2>/dev/null
  sudo wg-quick down "$WG_CONF_DIR/$CHINA_CONF" 2>/dev/null
  # Bring up selected connection
  if sudo wg-quick up "$WG_CONF_DIR/$CONF"; then
    yad --info --text="Connected to $SHOWNAME VPN!\n\nYour IP should now be $SHOWNAME."
  else
    yad --error --text="Failed to connect to $SHOWNAME VPN."
  fi
else
  yad --info --text="Cancelled."
fi

exit 0
