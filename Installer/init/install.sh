#!/bin/bash

log_info "Running additional INIT (main VM) setup..."

# Optional: configure hostname, local directories, etc.
# hostnamectl set-hostname my-main-vm

# Run ZeroTier controller setup
source "$(dirname "$0")/zerotier.sh"
install_zerotier_controller

log_info "INIT setup completed."
