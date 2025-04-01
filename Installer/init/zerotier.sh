#!/bin/bash

install_zerotier_controller() {
  log_info "Installing ZeroTier controller..."

  # Prepare dir
  mkdir -p /opt/ztcloud/zerotier
  cd /opt/ztcloud/zerotier

  # Install ZeroTier
  if ! command -v zerotier-one &>/dev/null; then
    log_info "Downloading and installing ZeroTier..."
    curl -s https://install.zerotier.com | bash
  else
    log_info "ZeroTier is already installed."
  fi

  # Enable and start service
  systemctl enable zerotier-one
  systemctl start zerotier-one

  sleep 5  # wait for identity generation
  ZT_IDENTITY_FILE="/var/lib/zerotier-one/identity.public"
  if [[ ! -f "$ZT_IDENTITY_FILE" ]]; then
    log_error "ZeroTier identity file not found."
    exit 1
  fi

  ZT_PUBLIC_ID=$(cat "$ZT_IDENTITY_FILE" | cut -d ':' -f1)
  log_info "ZeroTier public identity: $ZT_PUBLIC_ID"

  # Fetch public WAN IP
  WAN_IP=$(curl -s https://api.ipify.org)
  if [[ -z "$WAN_IP" ]]; then
    log_error "Failed to fetch public IP address."
    exit 1
  fi
  log_info "Detected public WAN IP: $WAN_IP"

  # Generate Moon config
  log_info "Creating Moon (planet) configuration..."
  zerotier-idtool initmoon identity.public
  MOON_ID=$(ls *.moon | sed 's/.moon//')

  jq ".roots[0].stableEndpoints = [\"$WAN_IP/9993\"]" "$MOON_ID.moon" > "$MOON_ID.moon.tmp"
  mv "$MOON_ID.moon.tmp" "$MOON_ID.moon"

  # Sign moon
  zerotier-idtool genmoon "$MOON_ID.moon"
  cp "$MOON_ID.moon.d" /var/lib/zerotier-one/moons.d/ -r

  # Restart ZeroTier to load moon
  systemctl restart zerotier-one

  log_info "Moon generated and applied. Moon ID: $MOON_ID"
  log_info "Your deploy nodes will need this moon file: /opt/ztcloud/zerotier/$MOON_ID.moon"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ZeroTier Controller ID: $ZT_PUBLIC_ID, Moon ID: $MOON_ID, WAN: $WAN_IP" >> "$LOGFILE"
}
