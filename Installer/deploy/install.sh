#!/bin/bash

log_info "Running additional DEPLOY (remote VM) setup..."

DEPLOY_DIR="$(dirname "$0")"
source "$DEPLOY_DIR/tailscale.sh"
install_tailscale_client

log_info "DEPLOY setup completed."
