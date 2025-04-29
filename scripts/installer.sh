#!/bin/bash

# Colors
YELLOW="\e[0;33m"
GREEN="\e[1;32m"
RED="\e[1;31m"
RESET="\e[0m"

# Display title
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                           UPML Installer                               ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}\n"

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}Please run as root.${RESET}"
  exit 1
fi

# Verify if the source file exists
if [[ ! -f "../upml.sh" ]]; then
  echo -e "${RED}Error: upml.sh not found. Please run this script from the 'scripts/' directory inside the project.${RESET}"
  exit 1
fi

# Check and install required dependencies
echo -e "${YELLOW}Checking and installing dependencies...${RESET}"

REQUIRED_PKGS=(curl deborphan bash-completion)

for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! dpkg -l | grep -qw "$pkg"; then
    echo -e "${YELLOW}Installing missing package: $pkg${RESET}"
    apt install -y "$pkg"
  fi
done

# Ask for Discord Webhook URL
read -rp "Enter your Discord Webhook URL (or leave blank to skip): " WEBHOOK_URL

# Check if /usr/local/bin exists
if [[ ! -d "/usr/local/bin" ]]; then
  echo -e "${YELLOW}Directory /usr/local/bin not found. Creating it...${RESET}"
  mkdir -p /usr/local/bin
fi

# Copy script to /usr/local/bin
cp ../upml.sh /usr/local/bin/upml
chmod +x /usr/local/bin/upml
chown root:root /usr/local/bin/upml
chmod 700 /usr/local/bin/upml

# Check if /var/log/upml exists
if [[ ! -d "/var/log/upml" ]]; then
  echo -e "${YELLOW}Directory /var/log/upml not found. Creating it...${RESET}"
  mkdir -p /var/log/upml
fi

# Install tab completion
if [[ -f "./upml_completion.sh" ]]; then
  echo -e "${YELLOW}Installing tab completion for UPML...${RESET}"
  cp ./upml_completion.sh /etc/bash_completion.d/upml
  chmod 644 /etc/bash_completion.d/upml
  echo -e "${GREEN}Tab completion installed.${RESET}"
else
  echo -e "${YELLOW}Tab completion script not found. Skipping.${RESET}"
fi

# Create or update configuration file
if [[ -n "$WEBHOOK_URL" ]]; then
  echo "DISCORD_WEBHOOK=\"$WEBHOOK_URL\"" >/etc/upml.conf
  echo "LOG_DIR=\"/var/log/upml\"" >>/etc/upml.conf
  echo -e "${GREEN}Configuration saved at /etc/upml.conf.${RESET}"
else
  echo "DISCORD_WEBHOOK=\"\"" >/etc/upml.conf
  echo "LOG_DIR=\"/var/log/upml\"" >>/etc/upml.conf
  echo -e "${YELLOW}No webhook configured. You can edit /etc/upml.conf later.${RESET}"
fi

# Display success message
echo -e "\n${GREEN}UPML installed successfully!${RESET}"
echo -e "${GREEN}You can now run it using: ${RESET}sudo upml\n"
