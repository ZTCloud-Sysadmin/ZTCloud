#!/bin/bash

install_tailscale_client() {
  log_info "Installing Tailscale client..."

  BIN_DIR="/opt/ZTCloud/bin"
  mkdir -p "$BIN_DIR"

  if [[ ! -f "$BIN_DIR/tailscale" ]]; then
    log_info "Downloading Tailscale binary..."
    curl -fsSL https://pkgs.tailscale.com/stable/tailscale_amd64.tgz | tar -xz --strip-components=1 -C "$BIN_DIR"
  fi

  export PATH="$BIN_DIR:$PATH"

  if ! pgrep -x tailscaled &>/dev/null; then
    log_info "Starting Tailscale daemon..."
    mkdir -p /var/lib/tailscale
    "$BIN_DIR/tailscaled" --tun=userspace-networking --socks5-server=localhost:1055 &
    sleep 2
  fi

  log_info "Tailscale client installed. Manual auth/login might still be required."
}
