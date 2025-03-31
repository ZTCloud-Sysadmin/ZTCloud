#!/bin/bash

log_info() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "\e[32m[$timestamp] [INFO]\e[0m $1"
  echo "[$timestamp] [INFO] $1" >> "$LOGFILE"
}

log_error() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "\e[31m[$timestamp] [ERROR]\e[0m $1" >&2
  echo "[$timestamp] [ERROR] $1" >> "$LOGFILE"
}

install_docker() {
  log_info "Installing Docker..."

  apt update
  apt install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      software-properties-common

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | \
      gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  systemctl enable docker
  systemctl start docker

  log_info "Docker installed and started."
}
