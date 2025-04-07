#!/bin/bash

# ============================================================
# ZTCloud Packages Validation
# Location: /opt/ztcloud/validate/packages-check.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

log_info "Validating base system packages installation"

# Loop through BASE_PACKAGES array defined in config.sh
for pkg in "${BASE_PACKAGES[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        log_info "Package '$pkg' is installed ✅"
    else
        log_error "Package '$pkg' is NOT installed ❌"
        exit 1
    fi
done

log_info "All essential packages validated successfully 🎯"

exit 0
