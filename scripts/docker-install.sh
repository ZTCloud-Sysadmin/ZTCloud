#!/bin/bash

# ============================================================
# Docker Installer Script for ZTCloud
# Location: $BASE_DIR/scripts/docker-install.sh
# ============================================================

log_info "Starting Docker installation..."

# Create container directories if they don't exist
mkdir -p "$IMAGES_DIR" "$NON_PERSISTANT_DIR"

if [ "$ENABLE_DRY_RUN" = "true" ]; then
    log_info "Dry-run: Would install Docker and set up directories."
    exit 0
fi

# Install required dependencies
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo \"$ID\") \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Update and install Docker packages
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker to start on boot
systemctl enable docker
systemctl start docker

log_info "Docker installation completed successfully."
