#!/bin/bash

log_info "Running final cleanup..."

# Restart sshd only after everything else is done
log_info "Restarting SSH service safely..."
#systemctl restart sshd

log_info "Cleanup complete."
