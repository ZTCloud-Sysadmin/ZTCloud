#!/bin/bash
# ============================================================
# ZTCloud Docker Installation
# Location: /opt/ztcloud/scripts/docker.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

log_info "Starting Docker installation and setup."

# ------------------------------------------------------------
# Step 1: Add Docker APT Repository
# ------------------------------------------------------------
log_info "Adding Docker's official GPG key and repository."

install_docker_repo() {
    install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        log_info "Docker GPG key added."
    else
        log_info "Docker GPG key already exists, skipping."
    fi

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
}

# ------------------------------------------------------------
# Step 2: Install Docker Packages
# ------------------------------------------------------------
install_docker_packages() {
    log_info "Installing Docker Engine and Compose plugin."
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# ------------------------------------------------------------
# Step 3: Setup Docker Storage Directory
# ------------------------------------------------------------
setup_docker_directories() {
    log_info "Setting up Docker storage under /opt/docker."
    mkdir -p /opt/docker/{data,config}
    chown "$ZTCL_SYSADMIN_UID:$ZTCL_SYSADMIN_GID" /opt/docker /opt/docker/data /opt/docker/config
    chmod 700 /opt/docker
}

# ------------------------------------------------------------
# Step 4: Configure Docker Daemon
# ------------------------------------------------------------
configure_docker_daemon() {
    log_info "Creating Docker daemon.json configuration."

    mkdir -p /etc/docker

    cat > /etc/docker/daemon.json <<EOF
{
    "data-root": "/opt/docker/data",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF

    log_info "Docker daemon.json created at /etc/docker/daemon.json."
}

# ------------------------------------------------------------
# Step 5: Reload and Enable Docker
# ------------------------------------------------------------
reload_and_enable_docker() {
    log_info "Reloading systemd and enabling Docker service."
    systemctl daemon-reexec
    systemctl enable docker
    systemctl restart docker
}

# ------------------------------------------------------------
# Step 6: Setup DOCKER_CONFIG for sysadmin
# ------------------------------------------------------------
setup_docker_cli_config() {
    log_info "Preparing Docker CLI config directory at /opt/docker/config."
    
    BASHRC_FILE="/home/ztcl-sysadmin/.bashrc"
    DOCKER_CONFIG_EXPORT="export DOCKER_CONFIG=/opt/docker/config"

    if ! grep -q "$DOCKER_CONFIG_EXPORT" "$BASHRC_FILE"; then
        echo "$DOCKER_CONFIG_EXPORT" >> "$BASHRC_FILE"
        log_info "Set DOCKER_CONFIG variable in $BASHRC_FILE."
    else
        log_info "DOCKER_CONFIG already set in $BASHRC_FILE."
    fi
}

# ------------------------------------------------------------
# Execute All Steps
# ------------------------------------------------------------
install_docker_repo
install_docker_packages
setup_docker_directories
configure_docker_daemon
reload_and_enable_docker
setup_docker_cli_config

log_info "Docker installation and setup completed successfully."

exit 0
