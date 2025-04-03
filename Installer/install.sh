#!/bin/bash

install_tailscale_client() {
  log_info "Installing Tailscale client from local .deb..."

  BIN_DIR="/opt/ZTCloud/bin"
  mkdir -p "$BIN_DIR"

  # Install from local .deb
  dpkg -i /opt/ZTCloud/installer/Installer/binary/tailscale/tailscale_1.82.0_amd64.deb

  ensure_custom_path

  # Copy tailscaled binary to managed bin dir
  cp $(which tailscaled) "$BIN_DIR/tailscaled"
  chmod +x "$BIN_DIR/tailscaled"

  # Create systemd unit for tailscaled
  cat <<EOF > /etc/systemd/system/tailscaled.service
[Unit]
Description=Tailscale Daemon
After=network.target

[Service]
ExecStart=$BIN_DIR/tailscaled --tun=userspace-networking --socks5-server=localhost:1055
Restart=always
User=root
WorkingDirectory=/opt/ZTCloud/
StandardOutput=append:/opt/log/installer/tailscaled.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable tailscaled
  systemctl start tailscaled

  log_info "Tailscale client installed and service started."
}
