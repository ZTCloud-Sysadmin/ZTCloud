#!/bin/bash
# ============================================================
# ZTCloud System User Creation
# Location: /opt/ztcloud/scripts/system-user.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh
source /opt/ztcloud/helpers/ssh_config.sh

# ------------------------------------------------------------
# Global Settings
# ------------------------------------------------------------
USER_SYSADMIN="ztcl-sysadmin"

# ------------------------------------------------------------
# Create system user
# ------------------------------------------------------------
create_system_user() {
    log_info "Creating system user $USER_SYSADMIN"

    if id "$USER_SYSADMIN" >/dev/null 2>&1; then
        log_warn "User $USER_SYSADMIN already exists. Skipping creation."
        return
    fi

    # Check if UID or GID already exist
    if getent passwd "$ZTCL_SYSADMIN_UID" >/dev/null || getent group "$ZTCL_SYSADMIN_GID" >/dev/null; then
        log_warn "UID $ZTCL_SYSADMIN_UID or GID $ZTCL_SYSADMIN_GID already in use. Creating user with automatic UID/GID."
        useradd -m -s /bin/bash "$USER_SYSADMIN"
    else
        log_info "Creating $USER_SYSADMIN with UID=$ZTCL_SYSADMIN_UID and GID=$ZTCL_SYSADMIN_GID"
        groupadd -g "$ZTCL_SYSADMIN_GID" "$USER_SYSADMIN"
        useradd -m -s /bin/bash -u "$ZTCL_SYSADMIN_UID" -g "$ZTCL_SYSADMIN_GID" "$USER_SYSADMIN"
    fi
}

# ------------------------------------------------------------
# Setup SSH key and authorized_keys
# ------------------------------------------------------------
setup_ssh_for_user() {
    local ssh_dir="/home/$USER_SYSADMIN/.ssh"
    local keys_dir="$BASE_DIR/keys"
    local private_key="$keys_dir/${USER_SYSADMIN}_id_rsa"
    local public_key="$ssh_dir/id_rsa.pub"

    log_info "Setting up SSH directory for $USER_SYSADMIN"

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    chown "$USER_SYSADMIN:$USER_SYSADMIN" "$ssh_dir"

    if [ ! -f "$ssh_dir/id_rsa" ]; then
        log_info "Generating SSH keypair for $USER_SYSADMIN"
        sudo -u "$USER_SYSADMIN" ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa" -N ""
    else
        log_warn "SSH keypair already exists for $USER_SYSADMIN. Skipping generation."
    fi

    log_info "Creating authorized_keys for $USER_SYSADMIN"
    cat "$public_key" > "$ssh_dir/authorized_keys"
    chmod 600 "$ssh_dir/authorized_keys"
    chown "$USER_SYSADMIN:$USER_SYSADMIN" "$ssh_dir/authorized_keys"

    # Copy private key to a safe location
    log_info "Saving private SSH key to $keys_dir"
    mkdir -p "$keys_dir"
    cp "$ssh_dir/id_rsa" "$private_key"
    chmod 600 "$private_key"
}

# ------------------------------------------------------------
# Setup passwordless sudo
# ------------------------------------------------------------
setup_passwordless_sudo() {
    local sudoers_file="/etc/sudoers.d/$USER_SYSADMIN"

    log_info "Configuring passwordless sudo for $USER_SYSADMIN"

    echo "$USER_SYSADMIN ALL=(ALL) NOPASSWD:ALL" > "$sudoers_file"
    chmod 440 "$sudoers_file"
}

# ------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------
log_info "Starting system-user setup"

create_system_user
setup_ssh_for_user
setup_passwordless_sudo

# Only modify sshd_config if requested
if [ "$DISABLE_SSH_PASSWORD_LOGIN" = "true" ]; then
    log_info "Disabling SSH password authentication"
    disable_ssh_password_login
fi

log_info "System user $USER_SYSADMIN setup completed."

# ------------------------------------------------------------
# WARN the user about the private key
# ------------------------------------------------------------
log_warn "Private SSH key saved at $BASE_DIR/keys/${USER_SYSADMIN}_id_rsa"
log_warn "Please download it securely over Tailscale and DELETE it from the server!"
log_warn "Failure to do so can create a security risk!"

exit 0
