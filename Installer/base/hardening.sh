#!/bin/bash

install_hardening() {
  log_info "Starting base system hardening..."

  # Install UFW and configure defaults
  log_info "Installing and configuring UFW..."
  apt install -y ufw
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow OpenSSH
  ufw --force enable
  log_info "UFW configured and enabled."

  # SSH: Disable root login
  log_info "Hardening SSH configuration..."
  sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  systemctl restart sshd
  log_info "SSH login hardened: root login disabled, password login disabled."

  # Enable automatic security updates
  log_info "Installing unattended-upgrades..."
  apt install -y unattended-upgrades
  dpkg-reconfigure --priority=low unattended-upgrades
  log_info "Automatic security updates enabled."

  log_info "System hardening complete."
}
