#!/bin/bash

install_zerotier_client() {
  log_info "Installing ZeroTier and joining controller network..."

  # Expected SSH connection details for the controller
  CONTROLLER_USER="root"
  CONTROLLER_HOST="192.168.10.100"  # Replace with actual --init IP
  MOON_DEST_DIR="/opt/ztcloud/zerotier"
  mkdir -p "$MOON_DEST_DIR"

  # Install ZeroTier if not present
  if ! command -v zerotier-one &>/dev/null; then
    log_info "Installing ZeroTier client..."
    curl -s https://install.zerotier.com | bash
  else
    log_info "ZeroTier is already installed."
  fi

  # Ensure service is running
  systemctl enable zerotier-one
  systemctl start zerotier-one

  # Fetch latest moon file from controller
  log_info "Fetching moon file from controller at $CONTROLLER_HOST..."
  scp "$CONTROLLER_USER@$CONTROLLER_HOST:/opt/ztcloud/zerotier/*.moon" "$MOON_DEST_DIR/"

  if [[ $? -ne 0 ]]; then
    log_error "Failed to fetch moon file from controller."
    exit 1
  fi

  # Move moon file into ZeroTier's moons.d
  cp "$MOON_DEST_DIR"/*.moon /var/lib/zerotier-one/moons.d/
  log_info "Moon file installed."

  # Restart to activate Moon
  systemctl restart zerotier-one
  sleep 5

  # Show identity
  if [[ -f /var/lib/zerotier-one/identity.public ]]; then
    ZT_ID=$(cut -d ':' -f1 /var/lib/zerotier-one/identity.public)
    log_info "This node's ZeroTier ID: $ZT_ID"
  fi

  log_info "ZeroTier client setup complete."
}
