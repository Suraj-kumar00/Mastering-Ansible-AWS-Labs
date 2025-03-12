#!/bin/bash

# Script to install Ansible on Ubuntu 22.04 with success/failure messages

set -e  # Exit immediately if a command exits with a non-zero status(means if any command fails the script will stop executing)

log_success() {
  echo -e "\e[32m[SUCCESS] $1\e[0m"
}

log_failure() {
  echo -e "\e[31m[FAILED] $1\e[0m" >&2
  exit 1
}

log_info() {
  echo -e "\e[34m[INFO] $1\e[0m"
}

# Update system packages
echo -e "\e[34m[INFO] Updating system packages...\e[0m"
sudo apt update -y && sudo apt upgrade -y && log_success "System packages updated successfully" || log_failure "Failed to update system packages"

# Install Ansible
echo -e "\e[34m[INFO] Installing Ansible...\e[0m"
sudo apt install -y ansible && log_success "Ansible installed successfully" || log_failure "Failed to install Ansible"

# Verify Ansible installation
echo -e "\e[34m[INFO] Checking installed Ansible version...\e[0m"
ansible --version && log_success "Ansible version installed successfully" || log_failure "Ansible version check failed"

# Print setup completion message
echo -e "\e[32m[SUCCESS] Ansible setup completed successfully!\e[0m"
