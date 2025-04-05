#!/bin/bash
# packages.sh - Installs base packages defined in config.sh

# Load configuration
source "/opt/ztcloud/config/config.sh"

# Function to install base packages
install_base_packages() {
    echo "Checking and installing base packages: ${BASE_PACKAGES[*]}"
    local missing_packages=()
    for pkg in "${BASE_PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "$pkg is not installed. Marking for installation."
            missing_packages+=("$pkg")
        else
            echo "$pkg is already installed."
        fi
    done

    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "Installing missing packages: ${missing_packages[*]}"
        apt-get update -y && apt-get install -y "${missing_packages[@]}"
        if [ $? -eq 0 ]; then
            echo "Successfully installed base packages."
        else
            echo "Failed to install base packages. Exiting."
            exit 1
        fi
    else
        echo "All base packages are already installed."
    fi
}

# Execute the function
install_base_packages
