#!/bin/bash

install_hardening() {
  log_info "Starting base system hardening..."

  # Install UFW and configure defaults
  log_info "Installing and configuring UFW..."
  apt install -y ufw
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow OpenSSH
  ufw allow 6022/tcp  # Pre-open port 6022 for future SSH move
  ufw --force enable
  log_info "UFW configured and enabled (OpenSSH + port 6022 allowed)."

  # SSH: Disable root login and password login
  log_info "Hardening SSH configuration..."
  sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  log_info "SSH login hardened: root login disabled, password login disabled (changes take effect after restart)."

  # Install and configure NTP hardening
  log_info "Installing and hardening NTP services..."
  apt install -y ntpdate systemd-timesyncd

  systemctl enable systemd-timesyncd
  systemctl start systemd-timesyncd

  # Force initial NTP sync with pool.ntp.org
  ntpdate -u pool.ntp.org

  # Optional: Customize systemd-timesyncd config
  TIMESYNC_CONF="/etc/systemd/timesyncd.conf"
  if [[ -f "$TIMESYNC_CONF" ]]; then
    sed -i 's|^#*NTP=.*|NTP=pool.ntp.org|' "$TIMESYNC_CONF"
    sed -i 's|^#*FallbackNTP=.*|FallbackNTP=pool.ntp.org|' "$TIMESYNC_CONF"
    systemctl restart systemd-timesyncd
    log_info "Systemd-timesyncd configured to use pool.ntp.org."
  else
    log_warn "Could not find $TIMESYNC_CONF to customize."
  fi

  # Enable automatic security updates
  log_info "Installing unattended-upgrades non-interactively..."
  export DEBIAN_FRONTEND=noninteractive
  apt install -y unattended-upgrades

  echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
  dpkg-reconfigure -f noninteractive unattended-upgrades

  # Confirm the config is active
  AUTO_UPGRADES_FILE="/etc/apt/apt.conf.d/20auto-upgrades"
  if [[ -f "$AUTO_UPGRADES_FILE" ]]; then
    log_info "Auto-upgrades config applied:"
    cat "$AUTO_UPGRADES_FILE" >> "$LOGFILE"
  else
    log_warn "Could not find $AUTO_UPGRADES_FILE after setup."
  fi

  log_info "Automatic security updates enabled."
  log_info "System hardening complete."
}
