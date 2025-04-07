#!/bin/bash

# ============================================================
# ZTCloud Validation Launcher
# Location: /opt/ztcloud/validate/validate.sh
# ============================================================

source /opt/ztcloud/config/config.sh
source /opt/ztcloud/helpers/common.sh

log_info "Launching full ZTCloud validation summary"

bash "$BASE_DIR/validate/validation-summary.sh"

exit $?
