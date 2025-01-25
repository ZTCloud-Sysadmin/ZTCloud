#!/bin/bash

# Define installation directories
BIN_DIR="/opt/ztcloud/bin"
ETC_DIR="/opt/ztcloud/etc"
SCRIPT_DIR="/opt/ztcloud/scripts/installer"
LOG_DIR="/opt/ztcloud/logs"
CONF_DIR="$ETC_DIR/conf.d"

# Define Supervisord binary version and URL
SUPERVISORD_VERSION="4.2.4"  # Replace with desired version
BINARY_URL="https://github.com/Supervisor/supervisor/releases/download/${SUPERVISORD_VERSION}/supervisord-${SUPERVISORD_VERSION}.linux-amd64"
SUPERVISORD_BINARY="$BIN_DIR/supervisord"

# Ensure required directories exist
echo "Creating directories..."
mkdir -p "$BIN_DIR" "$ETC_DIR" "$LOG_DIR" "$CONF_DIR"

# Download the binary
echo "Fetching Supervisord binary..."
wget -qO "$SUPERVISORD_BINARY" "$BINARY_URL"

# Verify download
if [ ! -f "$SUPERVISORD_BINARY" ]; then
    echo "Error: Failed to download Supervisord binary from $BINARY_URL"
    exit 1
fi

# Make the binary executable
chmod +x "$SUPERVISORD_BINARY"

# Create a symbolic link for supervisorctl (optional)
SUPERVISORCTL_BINARY="$BIN_DIR/supervisorctl"
ln -sf "$SUPERVISORD_BINARY" "$SUPERVISORCTL_BINARY"

# Create a base configuration file for Supervisord
echo "Creating base Supervisord configuration..."
cat <<EOL > "$ETC_DIR/supervisord.conf"
[unix_http_server]
file=/tmp/supervisor.sock   ; path to your socket file

[supervisord]
logfile=$LOG_DIR/supervisord.log ; main log file
pidfile=/tmp/supervisord.pid ; PID file
childlogdir=$LOG_DIR  ; where child process logs go

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use unix socket by default

[include]
files = $CONF_DIR/*.ini
EOL

# Create directories for additional configurations and logs
echo "Ensuring configuration and log directories exist..."
mkdir -p "$LOG_DIR"
mkdir -p "$CONF_DIR"

# Create a systemd service file for supervisord
echo "Setting up systemd service for Supervisord..."
cat <<EOL > /etc/systemd/system/supervisord.service
[Unit]
Description=Supervisord - Process Control System
After=network.target

[Service]
ExecStart=$BIN_DIR/supervisord -c $ETC_DIR/supervisord.conf
ExecStop=$BIN_DIR/supervisorctl shutdown
Restart=always
User=root
WorkingDirectory=/opt/ztcloud

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to apply changes
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable supervisord to start on boot
echo "Enabling Supervisord service..."
systemctl enable supervisord

# Start the Supervisord service
echo "Starting Supervisord service..."
systemctl start supervisord

# Test Supervisord installation
echo "Testing Supervisord binary..."
"$SUPERVISORD_BINARY" -v
if [ $? -ne 0 ]; then
    echo "Error: Supervisord binary failed to execute."
    exit 1
fi

echo "Supervisord version $(basename $SUPERVISORD_BINARY) installed successfully."
echo "Configuration file is located at: $ETC_DIR/supervisord.conf"
echo "Service is now managed by systemd (service name: supervisord)."
exit 0
