#!/bin/bash

install_zerotier_client() {
  log_info "Installing ZeroTier and joining controller network..."

  # Controller config
  CONTROLLER_USER="root"
  CONTROLLER_HOST="192.168.10.100"  # Update as needed
  MOON_DEST_DIR="/opt/ztcloud/zerotier"
  ZT_INSTALL_DIR="/opt/ZTCloud/bin/zerotier"
  ZT_DEB_PATH="/opt/ZTCloud/installer/binary/zerotier/deb/bookworm/zerotier-one_1.8.9_amd64.deb"

  mkdir -p "$MOON_DEST_DIR"
  mkdir -p "$ZT_INSTALL_DIR"

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

  # Create systemd unit
  log_info "Creating ZeroTier systemd service..."
  cat <<EOF > /etc/systemd/system/zerotier-one.service
[Unit]
Description=ZeroTier One Client
After=network.target

[Service]
ExecStart=/usr/local/bin/zerotier-one
ExecStartPost=/bin/sleep 2
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable zerotier-one
  systemctl start zerotier-one

  # Fetch Moon file
  log_info "Fetching moon file from controller at $CONTROLLER_HOST..."
  scp "$CONTROLLER_USER@$CONTROLLER_HOST:/opt/ztcloud/zerotier/*.moon" "$MOON_DEST_DIR/"

  if [[ $? -ne 0 ]]; then
    log_error "Failed to fetch moon file from controller."
    exit 1
  fi

  cp "$MOON_DEST_DIR"/*.moon /var/lib/zerotier-one/moons.d/
  log_info "Moon file installed."

  systemctl restart zerotier-one
  sleep 5

  if [[ -f /var/lib/zerotier-one/identity.public ]]; then
    ZT_ID=$(cut -d ':' -f1 /var/lib/zerotier-one/identity.public)
    log_info "This node's ZeroTier ID: $ZT_ID"
  fi

  log_info "ZeroTier client setup complete."
}
