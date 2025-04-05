#!/bin/bash
# system-user.sh - Create ztcl-sysadmin user and configure SSH access

source "/opt/ztcloud/config/config.sh"
source "/opt/ztcloud/helpers/common.sh"
source "/opt/ztcloud/helpers/ssh_config.sh"

USERNAME="ztcl-sysadmin"
SSH_DIR="/home/$USERNAME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SUDOERS_FILE="/etc/sudoers.d/$USERNAME"

# Create the system user if it doesn't exist
if id "$USERNAME" >/dev/null 2>&1; then
    log_info "User $USERNAME already exists."
else
    log_info "Creating system user $USERNAME"
    useradd -m -s /bin/bash "$USERNAME"
fi

# Ensure SSH directory exists with proper permissions
log_info "Setting up SSH directory for $USERNAME"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USERNAME:$USERNAME" "$SSH_DIR"

# Create empty authorized_keys if not exists
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    log_info "Creating empty authorized_keys for $USERNAME"
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"
else
    log_info "authorized_keys already exists for $USERNAME"
fi

# Setup passwordless sudo
log_info "Configuring passwordless sudo for $USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"
chown root:root "$SUDOERS_FILE"

# Optionally disable SSH password login
if [ "${DISABLE_SSH_PASSWORD_LOGIN}" = "true" ]; then
    disable_ssh_password_login
else
    log_info "Leaving SSH password login settings unchanged."
fi

log_info "System user $USERNAME setup completed."
