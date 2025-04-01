#!/bin/bash

log_info "Running additional DEPLOY (remote VM) setup..."

# Load and run ZeroTier join logic
source "$(dirname "$0")/zerotier.sh"
install_zerotier_client

log_info "DEPLOY setup completed."
