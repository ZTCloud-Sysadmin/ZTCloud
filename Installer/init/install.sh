#!/bin/bash

log_info "Running additional INIT (main VM) setup..."

INIT_DIR="$(dirname "$0")"
source "$INIT_DIR/zerotier.sh"
install_zerotier_controller

log_info "INIT setup completed."