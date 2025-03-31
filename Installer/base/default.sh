#!/bin/bash

install_basic_packages() {
  log_info "Installing basic packages..."

  apt update
  apt install -y \
      sudo \
      curl \
      wget \
      ca-certificates \
      gnupg \
      lsb-release \
      software-properties-common

  log_info "Basic packages installed."

  SYSUSER="sysadmin"

  if id "$SYSUSER" &>/dev/null; then
    log_info "User '$SYSUSER' already exists. Skipping creation."
  else
    log_info "Creating user '$SYSUSER'..."
    useradd -m -s /bin/bash "$SYSUSER"
    PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    echo "$SYSUSER:$PASSWORD" | chpasswd
    log_info "Generated password for '$SYSUSER': $PASSWORD"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Generated password for $SYSUSER: $PASSWORD" >> "$LOGFILE"
  fi

  usermod -aG sudo "$SYSUSER"
  echo "$SYSUSER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$SYSUSER"
  chmod 0440 "/etc/sudoers.d/$SYSUSER"

  log_info "User '$SYSUSER' configured with sudo access (NOPASSWD)."
}
