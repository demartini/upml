#!/bin/bash

# Colors
YELLOW="\e[0;33m"
GREEN="\e[1;32m"
RED="\e[1;31m"
RESET="\e[0m"

# Display title
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                          UPML Uninstaller                              ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}\n"

# Confirm uninstallation
echo -e "${RED}WARNING: This will completely remove UPML and all related files!${RESET}"
read -rp "Are you sure you want to proceed? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then

  echo -e "\n${YELLOW}Starting uninstallation...${RESET}\n"

  # Remove binary if exists
  if [[ -f "/usr/local/bin/upml" ]]; then
    rm -f /usr/local/bin/upml
    echo -e "${GREEN}Removed: /usr/local/bin/upml${RESET}"
  else
    echo -e "${YELLOW}Not found: /usr/local/bin/upml. Skipping.${RESET}"
  fi

  # Remove log directory if exists
  if [[ -d "/var/log/upml" ]]; then
    rm -rf /var/log/upml
    echo -e "${GREEN}Removed: /var/log/upml${RESET}"
  else
    echo -e "${YELLOW}Not found: /var/log/upml. Skipping.${RESET}"
  fi

  # Remove config file if exists
  if [[ -f "/etc/upml.conf" ]]; then
    rm -f /etc/upml.conf
    echo -e "${GREEN}Removed: /etc/upml.conf${RESET}"
  else
    echo -e "${YELLOW}Not found: /etc/upml.conf. Skipping.${RESET}"
  fi

  # Remove tab completion if exists
  if [[ -f "/etc/bash_completion.d/upml" ]]; then
    rm -f /etc/bash_completion.d/upml
    echo -e "${GREEN}Removed: /etc/bash_completion.d/upml${RESET}"
  else
    echo -e "${YELLOW}Not found: /etc/bash_completion.d/upml. Skipping.${RESET}"
  fi

  echo -e "\n${GREEN}UPML uninstalled successfully!${RESET}\n"

else
  echo -e "\n${YELLOW}Uninstallation canceled.${RESET}\n"
fi
