#!/bin/bash
# ssh_config.sh - Helper functions to manage /etc/ssh/sshd_config

backup_sshd_config() {
    local backup_file="/etc/ssh/sshd_config.bak-$(date '+%Y%m%d%H%M%S')"
    log_info "Backing up /etc/ssh/sshd_config to $backup_file"
    cp /etc/ssh/sshd_config "$backup_file"
}

set_sshd_option() {
    local key="$1"
    local value="$2"
    
    log_info "Setting $key to $value in sshd_config"

    # Backup first
    backup_sshd_config

    # Edit or add option
    if grep -q "^#\?\s*${key}\b" /etc/ssh/sshd_config; then
        sed -i "s|^#\?\s*${key}.*|${key} ${value}|g" /etc/ssh/sshd_config
    else
        echo "${key} ${value}" >> /etc/ssh/sshd_config
    fi
}

disable_ssh_password_login() {
    log_info "Disabling SSH password authentication"
    set_sshd_option "PasswordAuthentication" "no"
}

enable_ssh_password_login() {
    log_info "Enabling SSH password authentication"
    set_sshd_option "PasswordAuthentication" "yes"
}
