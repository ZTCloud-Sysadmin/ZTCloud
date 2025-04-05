#!/bin/bash
# ============================================================
# ZTCloud System User Creation
# Location: /opt/ztcloud/scripts/system-user.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh
source /opt/ztcloud/helpers/ssh_config.sh

# ------------------------------------------------------------
# Create system user
# ------------------------------------------------------------
create_system_user() {
    local user="ztcl-sysadmin"

    log_info "Creating system user $user"
    if ! id "$user" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$user"
    else
        log_warn "User $user already exists. Skipping creation."
    fi
}

# ------------------------------------------------------------
# Setup SSH key and authorized_keys
# ------------------------------------------------------------
setup_ssh_for_user() {
    local user="ztcl-sysadmin"
    local ssh_dir="/home/$user/.ssh"
    local keys_dir="$BASE_DIR/keys"
    local private_key="$keys_dir/${user}_id_rsa"
    local public_key="$ssh_dir/id_rsa.pub"

    log_info "Setting up SSH directory for $user"

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    chown "$user:$user" "$ssh_dir"

    if [ ! -f "$ssh_dir/id_rsa" ]; then
        log_info "Generating SSH keypair for $user"
        sudo -u "$user" ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa" -N ""
    else
        log_warn "SSH keypair already exists for $user. Skipping generation."
    fi

    log_info "Creating authorized_keys for $user"
    cat "$public_key" > "$ssh_dir/authorized_keys"
    chmod 600 "$ssh_dir/authorized_keys"
    chown "$user:$user" "$ssh_dir/authorized_keys"

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
    local user="ztcl-sysadmin"
    local sudoers_file="/etc/sudoers.d/$user"

    log_info "Configuring passwordless sudo for $user"

    echo "$user ALL=(ALL) NOPASSWD:ALL" > "$sudoers_file"
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

log_info "System user ztcl-sysadmin setup completed."

# ------------------------------------------------------------
# WARN the user about the private key
# ------------------------------------------------------------
log_warn "Private SSH key saved at $BASE_DIR/keys/${user}_id_rsa"
log_warn "Please download it securely over Tailscale and DELETE it from the server!"
log_warn "Failure to do so can create a security risk!"

exit 0
