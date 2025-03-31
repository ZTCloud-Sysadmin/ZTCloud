#!/bin/bash

install_docker() {
  log_info "Installing Docker..."

  # Install Docker from Docker's official repository
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | \
      gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  systemctl enable docker
  systemctl start docker

  log_info "Docker installed and started."

  # Ensure 'docker' group exists with GID 1000 (if possible)
  if getent group docker > /dev/null; then
    log_info "'docker' group already exists."
  else
    if getent group 1000 > /dev/null; then
      groupadd docker
      log_info "'docker' group created with default GID."
    else
      groupadd -g 1000 docker
      log_info "'docker' group created with GID 1000."
    fi
  fi

  # Add sysadmin to docker group
  SYSUSER="sysadmin"
  if id "$SYSUSER" &>/dev/null; then
    usermod -aG docker "$SYSUSER"
    log_info "User '$SYSUSER' added to 'docker' group."
  else
    log_error "User '$SYSUSER' does not exist — skipping docker group assignment."
  fi

  # Set up default container paths
  mkdir -p /opt/containers/ZTCloud
  mkdir -p /opt/containers/images
  mkdir -p /opt/containers/bin

  log_info "Created default Docker directories under /opt/containers/"

  # Install ztcl-docker helper script
  cat << 'EOF' > /opt/containers/bin/ztcl-docker
#!/bin/bash

USER_NAME="sysadmin"
UID=$(id -u "$USER_NAME")
GID=$(getent group docker | cut -d: -f3)

if [[ -z "$UID" || -z "$GID" ]]; then
  echo "[ERROR] Could not determine UID or GID for $USER_NAME"
  exit 1
fi

echo "[INFO] Running container as $USER_NAME (UID:$UID, GID:$GID)"
docker "$@"
EOF

  chmod +x /opt/containers/bin/ztcl-docker
  log_info "Installed ztcl-docker to /opt/containers/bin/ztcl-docker"

  # Add docker-sudo to global PATH if not already
  if ! grep -q "/opt/containers/bin" <<< "$PATH"; then
    echo 'export PATH="/opt/containers/bin:$PATH"' >> /etc/profile.d/ztcloud-path.sh
    chmod +x /etc/profile.d/ztcloud-path.sh
    log_info "Added /opt/containers/bin to system PATH via /etc/profile.d/ztcloud-path.sh"
  fi
}
