#!/bin/bash
# ============================================================
# ZTCloud Docker Validation
# Location: /opt/ztcloud/validate/docker-check.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

log_info "Starting Docker validation checks."

# ------------------------------------------------------------
# Check if Docker service is active
# ------------------------------------------------------------
if systemctl is-active --quiet docker; then
    log_info "Docker service is running."
else
    log_error "Docker service is NOT running."
    exit 1
fi

# ------------------------------------------------------------
# Check Docker directories
# ------------------------------------------------------------
check_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        log_info "Directory exists: $dir"
    else
        log_error "Missing directory: $dir"
        exit 1
    fi
}

log_info "Checking Docker data and config directories."
check_directory "/opt/docker"
check_directory "/opt/docker/data"
check_directory "/opt/docker/config"

# ------------------------------------------------------------
# Check ownership
# ------------------------------------------------------------
check_ownership() {
    local dir="$1"
    local owner
    owner=$(stat -c "%u:%g" "$dir")
    if [ "$owner" = "$ZTCL_SYSADMIN_UID:$ZTCL_SYSADMIN_GID" ]; then
        log_info "Correct ownership for $dir ($owner)"
    else
        log_error "Incorrect ownership for $dir. Found $owner."
        exit 1
    fi
}

log_info "Validating ownership of Docker directories."
check_ownership "/opt/docker"
check_ownership "/opt/docker/data"
check_ownership "/opt/docker/config"

# ------------------------------------------------------------
# Check daemon.json exists
# ------------------------------------------------------------
if [ -f "/etc/docker/daemon.json" ]; then
    log_info "Found Docker daemon.json configuration."
else
    log_error "Missing /etc/docker/daemon.json!"
    exit 1
fi

# ------------------------------------------------------------
# Verify Docker is using /opt/docker/data
# ------------------------------------------------------------
docker_root_dir=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null)

if [[ "$docker_root_dir" == "/opt/docker/data" ]]; then
    log_info "Docker is correctly using /opt/docker/data as root."
else
    log_error "Docker root directory mismatch. Found: $docker_root_dir"
    exit 1
fi

log_info "Docker validation checks passed successfully."
exit 0
