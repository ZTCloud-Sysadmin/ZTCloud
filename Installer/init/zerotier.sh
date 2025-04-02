#!/bin/bash

install_zerotier_controller() {
  log_info "Installing ZeroTier controller..."

  # Prepare install paths
  ZT_INSTALL_DIR="/opt/ZTCloud/bin/zerotier"
  ZT_DEB_PATH="/opt/ZTCloud/installer/binary/zerotier/deb/bookworm/zerotier-one_1.8.9_amd64.deb"
  mkdir -p "$ZT_INSTALL_DIR"
  mkdir -p /opt/ztcloud/zerotier

  # Install from .deb if not already installed
  if ! command -v zerotier-one &>/dev/null; then
    log_info "Installing ZeroTier from local .deb package..."
    if [[ ! -f "$ZT_DEB_PATH" ]]; then
      log_error "ZeroTier .deb file not found at $ZT_DEB_PATH"
      exit 1
    fi

    dpkg -x "$ZT_DEB_PATH" "$ZT_INSTALL_DIR"
    ln -sf "$ZT_INSTALL_DIR/usr/sbin/zerotier-one" /usr/local/bin/zerotier-one
    ln -sf "$ZT_INSTALL_DIR/usr/sbin/zerotier-idtool" /usr/local/bin/zerotier-idtool
  else
    log_info "ZeroTier is already installed."
  fi

  # Setup systemd service manually
  log_info "Configuring ZeroTier systemd service..."
  cat <<EOF > /etc/systemd/system/zerotier-one.service
[Unit]
Description=ZeroTier One Controller
After=network.target

[Service]
ExecStart=/usr/local/bin/zerotier-one
ExecStartPost=/bin/sleep 2
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable zerotier-one
  systemctl start zerotier-one

  sleep 5  # wait for identity generation
  ZT_IDENTITY_FILE="/var/lib/zerotier-one/identity.public"
  if [[ ! -f "$ZT_IDENTITY_FILE" ]]; then
    log_error "ZeroTier identity file not found."
    exit 1
  fi

  ZT_PUBLIC_ID=$(cut -d ':' -f1 "$ZT_IDENTITY_FILE")
  log_info "ZeroTier public identity: $ZT_PUBLIC_ID"

  # Fetch public WAN IP
  WAN_IP=$(curl -s https://api.ipify.org)
  if [[ -z "$WAN_IP" ]]; then
    log_error "Failed to fetch public IP address."
    exit 1
  fi
  log_info "Detected public WAN IP: $WAN_IP"

  # Generate Moon config
  cd /opt/ztcloud/zerotier
  log_info "Creating Moon (planet) configuration..."
  zerotier-idtool initmoon "$ZT_IDENTITY_FILE"
  MOON_ID=$(ls *.moon | sed 's/.moon//')

  jq ".roots[0].stableEndpoints = [\"$WAN_IP/9993\"]" "$MOON_ID.moon" > "$MOON_ID.moon.tmp"
  mv "$MOON_ID.moon.tmp" "$MOON_ID.moon"

  # Sign moon and deploy
  zerotier-idtool genmoon "$MOON_ID.moon"
  mkdir -p /var/lib/zerotier-one/moons.d
  cp "$MOON_ID.moon.d" /var/lib/zerotier-one/moons.d/ -r

  systemctl restart zerotier-one

  log_info "Moon generated and applied. Moon ID: $MOON_ID"
  log_info "Your deploy nodes will need this moon file: /opt/ztcloud/zerotier/$MOON_ID.moon"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ZeroTier Controller ID: $ZT_PUBLIC_ID, Moon ID: $MOON_ID, WAN: $WAN_IP" >> "$LOGFILE"
}
