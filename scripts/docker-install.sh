#!/bin/bash

# ============================================================
# Docker Installer Script for ZTCloud
# Location: $BASE_DIR/scripts/docker-install.sh
# ============================================================

BASE_DIR="/opt/ztcloud"
source "$BASE_DIR/helpers/common.sh"

log_info "Starting Docker installation..."

# Define directory structure
DOCKER_SERVICE_DIR="/opt/services/docker"
DOCKER_ETC="$DOCKER_SERVICE_DIR/etc"
DOCKER_LIB="$DOCKER_SERVICE_DIR/lib"
DOCKER_IMAGES="$DOCKER_SERVICE_DIR/images"
DOCKER_NON_PERSISTANT="$DOCKER_IMAGES/non-persistant"
DOCKER_SYSTEMD="/etc/systemd/system/docker.service.d"

CONTAINERD_SERVICE_DIR="/opt/services/containerd"
CONTAINERD_ETC="$CONTAINERD_SERVICE_DIR/etc"
CONTAINERD_SYSTEMD="/etc/systemd/system/containerd.service.d"

ZT_VOLUMES_BASE="$BASE_DIR/containers"

# UID:GID for ZTCloud service user
ZT_UID=1099
ZT_GID=1099

# Create all required directories
mkdir -p \
  "$DOCKER_ETC" \
  "$DOCKER_LIB" \
  "$DOCKER_IMAGES" \
  "$DOCKER_NON_PERSISTANT" \
  "$DOCKER_SYSTEMD" \
  "$CONTAINERD_ETC" \
  "$CONTAINERD_SYSTEMD" \
  "$ZT_VOLUMES_BASE"

# Set ownership for ZTCloud-managed paths
chown -R "$ZT_UID:$ZT_GID" "$DOCKER_IMAGES"
chown -R "$ZT_UID:$ZT_GID" "$DOCKER_NON_PERSISTANT"
chown -R "$ZT_UID:$ZT_GID" "$ZT_VOLUMES_BASE"

if [ "$ENABLE_DRY_RUN" = "true" ]; then
    log_info "Dry-run: Would install Docker and set up directories."
    exit 0
fi

# Install dependencies
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo \"$ID\") \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install Docker and containerd
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create Docker daemon.json with custom data-root
cat > "$DOCKER_ETC/daemon.json" <<EOF
{
  "data-root": "$DOCKER_LIB"
}
EOF

# Override Docker systemd service to use custom config path
cat > "$DOCKER_SYSTEMD/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --config-file=$DOCKER_ETC/daemon.json
EOF

# Create containerd config
cat > "$CONTAINERD_ETC/config.toml" <<EOF
version = 2
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
[plugins."io.containerd.grpc.v1.cri".cni]
  bin_dir = "/opt/cni/bin"
  conf_dir = "/etc/cni/net.d"
EOF

# Override containerd systemd service to use custom config path
cat > "$CONTAINERD_SYSTEMD/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/containerd --config $CONTAINERD_ETC/config.toml
EOF

# Reload systemd and start services
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable containerd docker
systemctl restart containerd
systemctl restart docker

log_info "Docker and containerd installed and configured successfully."
