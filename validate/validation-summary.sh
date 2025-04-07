#!/bin/bash

# ============================================================
# ZTCloud Validation Summary
# Location: /opt/ztcloud/validate/validation-summary.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

log_info "Starting ZTCloud validation summary"

# ------------------------------------------------------------
# Prepare
# ------------------------------------------------------------
summary_passed=0
summary_failed=0

# ------------------------------------------------------------
# Run Each Validation
# ------------------------------------------------------------
for check in "${VALIDATION_PIPELINE[@]}"; do
    check_path="$BASE_DIR/validate/$check"
    if [ -f "$check_path" ]; then
        log_info "Running validation check: $check"
        bash "$check_path"
        if [ $? -eq 0 ]; then
            summary_passed=$((summary_passed + 1))
        else
            summary_failed=$((summary_failed + 1))
        fi
    else
        log_warn "Validation script not found: $check"
    fi
done

# ------------------------------------------------------------
# Summary Output
# ------------------------------------------------------------
echo ""
echo -e "${COLOR_INFO}=============================================${COLOR_RESET}"
echo -e "${COLOR_INFO}ZTCloud Validation Summary:${COLOR_RESET}"
echo -e "${COLOR_INFO}  ✔️ Passed: ${summary_passed}${COLOR_RESET}"
echo -e "${COLOR_INFO}  ❌ Failed: ${summary_failed}${COLOR_RESET}"
echo -e "${COLOR_INFO}=============================================${COLOR_RESET}"
echo ""

# ------------------------------------------------------------
# Exit Code
# ------------------------------------------------------------
if [ "$summary_failed" -eq 0 ]; then
    log_info "All validation checks passed successfully 🎯"
    exit 0
else
    log_error "Some validation checks failed ❌. Please review logs."
    exit 1
fi
