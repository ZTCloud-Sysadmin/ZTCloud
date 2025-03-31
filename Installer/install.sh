#!/bin/bash
set -e

ACTION="$1"

if [[ -z "$ACTION" ]]; then
    echo "Usage: $0 [--init | --deploy]"
    exit 1
fi

# Load shared utilities + Docker install logic
source "$(dirname "$0")/base.sh"

# Run shared Docker setup
install_docker

# Branch to mode-specific setup
case "$ACTION" in
  --init)
    log_info "Continuing with INIT setup..."
    source "$(dirname "$0")/init/install.sh"
    ;;
  --deploy)
    log_info "Continuing with DEPLOY setup..."
    source "$(dirname "$0")/deploy/install.sh"
    ;;
  *)
    log_error "Unknown option: $ACTION"
    exit 1
    ;;
esac
