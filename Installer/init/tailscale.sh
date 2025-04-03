#!/bin/bash

install_tailscale_controller() {
  log_info "Installing Tailscale + Headscale from local .debs..."

  BIN_DIR="/opt/ZTCloud/bin"
  CONFIG_DIR="/opt/ZTCloud/internal/headscale"
  mkdir -p "$BIN_DIR" "$CONFIG_DIR/certs" "$CONFIG_DIR/db"

  # Install from local .debs
  dpkg -i /opt/ZTCloud/installer/Installer/binary/tailscale/tailscale_1.82.0_amd64.deb
  dpkg -i /opt/ZTCloud/installer/Installer/binary/tailscale/headscale_0.25.1_linux_amd64.deb

  ensure_custom_path

  # Copy headscale binary to our bin dir for systemd compatibility
  cp $(which headscale) "$BIN_DIR/headscale"
  cp $(which tailscaled) "$BIN_DIR/tailscaled"
  chmod +x "$BIN_DIR"/*

  # Write config.yaml
  cat <<EOF > /etc/headscale/config.yaml
server_url: http://127.0.0.1:8080
listen_addr: 0.0.0.0:8080
private_key_path: /opt/ZTCloud/internal/headscale/certs/private.key
noise:
  private_key_path: /opt/ZTCloud/internal/headscale/certs/noise_private.key
db_type: sqlite
db_path: /opt/ZTCloud/internal/headscale/db/db.sqlite
ip_prefixes:
  - 100.64.0.0/10
log:
  level: info
  format: text
EOF

  # Generate headscale keys if missing
  if [[ ! -f "$CONFIG_DIR/certs/private.key" ]]; then
    log_info "Generating headscale private keys..."
    $BIN_DIR/headscale generate private-key > "$CONFIG_DIR/certs/private.key"
    $BIN_DIR/headscale generate noise-key > "$CONFIG_DIR/certs/noise_private.key"
  fi

  # Create systemd units
  cat <<EOF > /etc/systemd/system/headscale.service
[Unit]
Description=Headscale Controller
After=network.target

[Service]
ExecStart=$BIN_DIR/headscale serve
Restart=always
User=root
WorkingDirectory=/opt/ZTCloud/
StandardOutput=append:/opt/log/installer/headscale.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF

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
  systemctl enable headscale tailscaled
  systemctl start headscale tailscaled

  log_info "Tailscale + Headscale controller installed and started."
}
