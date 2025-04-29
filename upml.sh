#!/bin/bash

# Load config if exists
CONFIG_FILE="/etc/upml.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# Defaults if config not loaded
VERSION="1.0.0"
DISCORD_WEBHOOK="${DISCORD_WEBHOOK:-}"
LOG_DIR="${LOG_DIR:-/var/log/upml}"
LOGFILE="${LOG_DIR}/upml-$(date +%F_%H-%M-%S).log"
DRY_RUN=false
DISCORD_ENABLED=true
DRY_RUN=false
DISCORD_ENABLED=true

# Colors
YELLOW="\e[0;33m"
RED="\e[1;31m"
RESET="\e[0m"

# Check if running as root (except if dry-run)
if [[ "$EUID" -ne 0 && "$DRY_RUN" = false ]]; then
  echo -e "${RED}Please run as root or with sudo.${RESET}"
  exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -d | --dry-run)
    DRY_RUN=true
    shift
    ;;
  -n | --no-discord)
    DISCORD_ENABLED=false
    shift
    ;;
  -l | --logfile)
    LOGFILE="$2"
    shift 2
    ;;
  -s | --set-webhook)
    echo "Enter the new Discord Webhook URL (leave blank to disable notifications):"
    read -r new_webhook

    if [[ -z "$new_webhook" ]]; then
      new_webhook=""
    fi

    {
      echo "DISCORD_WEBHOOK=\"$new_webhook\""
      echo "LOG_DIR=\"/var/log/upml\""
    } >/etc/upml.conf

    echo -e "${GREEN}Discord Webhook updated successfully in /etc/upml.conf.${RESET}"
    exit 0
    ;;
  -c | --show-config)
    echo -e "${YELLOW}upml - Update My Linux${RESET}\n"
    if [[ -f /etc/upml.conf ]]; then
      source /etc/upml.conf
      echo -e "${YELLOW}Current Configuration:${RESET}"
      echo "Discord Webhook: ${DISCORD_WEBHOOK:-Not Set}"
      echo "Log Directory: ${LOG_DIR:-/var/log/upml}"
    else
      echo -e "${RED}Configuration file not found at /etc/upml.conf${RESET}"
    fi
    exit 0
    ;;
  -h | --help)
    echo -e "
${YELLOW}upml - Update My Linux${RESET}

Usage: upml [OPTIONS]

Options:
  -d, --dry-run       Simulate all operations without making changes
  -n, --no-discord    Disable all Discord notifications
  -l, --logfile PATH  Save logs to a custom file path
  -s, --set-webhook   Set or update your Discord Webhook URL
  -c, --show-config   Display the current configuration
  -h, --help          Display this help message
  -v, --version       Display the current version
"
    exit 0
    ;;
  -v | --version)
    echo "upml, version $VERSION"
    exit 0
    ;;
  *)
    echo -e "${RED}Unknown option: $1${RESET}"
    echo "Use '--help' to see available options."
    exit 1
    ;;
  esac
done

# Functions

display_banner() {
  echo -e "${YELLOW}"
  cat <<"EOF"
 _   _ _ ____  __  __ _
| | | | |  _ \|  \/  | |
| | | | | |_) | |\/| | |
| |_| | |  __/| |  | | |___
 \___/|_|_|   |_|  |_|_____|

    Up My Linux - UPML
EOF
  echo -e "${RESET}\n"
}

display_box() {
  local text="$1"
  local width=76

  local border_top_bottom
  border_top_bottom=$(printf '═%.0s' $(seq 1 $width))

  local text_width
  text_width=${#text}

  local left_padding
  left_padding=$(((width - text_width) / 2))

  local right_padding
  right_padding=$((width - text_width - left_padding))

  echo -e "${YELLOW}"
  printf "╔%s╗\n" "$border_top_bottom"
  printf "║%*s%s%*s║\n" "$left_padding" "" "$text" "$right_padding" ""
  printf "╚%s╝\n" "$border_top_bottom"
  echo -e "${RESET}\n"
  sleep 1
}

send_discord_notification() {
  local message="$1"
  if $DISCORD_ENABLED && [[ -n "$DISCORD_WEBHOOK" ]]; then
    if $DRY_RUN; then
      message="[DRY-RUN] $message"
    fi
    curl -sf -H "Content-Type: application/json" \
      -X POST \
      -d "{\"content\": \"$message\"}" \
      "$DISCORD_WEBHOOK" >/dev/null || echo -e "${RED}Failed to send Discord notification.${RESET}"
  fi
}

send_discord_file() {
  local file="$1"
  if $DISCORD_ENABLED && [[ -n "$DISCORD_WEBHOOK" ]]; then
    curl -sf -F "file1=@${file}" \
      -F "payload_json={\"content\": \":page_facing_up: **System Update Log File** from $(hostname)\"}" \
      "$DISCORD_WEBHOOK" >/dev/null || echo -e "${RED}Failed to send log file to Discord.${RESET}"
  fi
}

# Error handling
# shellcheck disable=SC2317
handle_error() {
  local lineno=$1
  local command=$2
  echo -e "${RED}Error at line $lineno: '$command'.${RESET}" | tee -a "$LOGFILE"
  send_discord_notification ":x: **Error** at line $lineno: \`$command\`"
  exit 1
}

trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# Prepare environment
mkdir -p "$LOG_DIR"

# Clean old logs (older than 30 days)
find "$LOG_DIR" -name "upml-*.log" -type f -mtime +30 -exec rm {} \; || true

# Start of Script
display_banner
display_box "Starting System Update"

{
  echo "----------------------------------------"
  echo "System update started: $(date)"
  echo "----------------------------------------"
} | tee -a "$LOGFILE"

send_discord_notification ":arrows_counterclockwise: **System Update Started** - $(hostname) at $(date)"

tasks=(
  "Fixing Broken Packages:apt-get -y -f install"
  "Updating Database:apt-get update -y"
  "Upgrading Packages:apt-get upgrade -y"
  "Starting Full Upgrade:apt-get dist-upgrade -y"
  "Removing Unnecessary Packages:apt-get autoremove -y"
  "Cleaning Local Repository:apt-get autoclean -y"
  "Clean Remaining Packages:apt-get clean -y"
  "Cleaning Orphaned Packages:deborphan | xargs apt-get -y remove"
)

for task in "${tasks[@]}"; do
  IFS=":" read -r title cmd <<<"$task"
  display_box "$title"

  if $DRY_RUN; then
    echo "[DRY-RUN] $cmd" | tee -a "$LOGFILE"
  else
    eval "$cmd" | tee -a "$LOGFILE"
  fi
done

# Health Check
display_box "System Health Check"

if $DRY_RUN; then
  echo "[DRY-RUN] Health check skipped." | tee -a "$LOGFILE"
else
  {
    echo "Disk Usage:"
    df -h

    echo -e "\nMemory Usage:"
    free -m

    echo -e "\nTop Processes:"
    top -b -n 1 | head -n 10
  } | tee -a "$LOGFILE"
fi

# Finishing
display_box "System Update Completed"
{
  echo "----------------------------------------"
  echo "System update completed: $(date)"
  echo "----------------------------------------"
} | tee -a "$LOGFILE"

send_discord_notification ":white_check_mark: **System Update Completed** - $(hostname) at $(date)"

# Reboot check
if [[ -f /var/run/reboot-required ]]; then
  echo -e "${RED}"
  display_box "Reboot Required!"
  echo -e "${RESET}"

  if ! $DRY_RUN; then
    read -r -p "Reboot now? (y/n): " REBOOT
    if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
      echo "Rebooting..." | tee -a "$LOGFILE"
      send_discord_notification ":arrows_counterclockwise: **Rebooting** - $(hostname)"
      reboot
    else
      echo "Reboot skipped." | tee -a "$LOGFILE"
      send_discord_notification ":no_entry: **Reboot Skipped** - $(hostname)"
    fi
  else
    echo "[DRY-RUN] Skipping reboot prompt." | tee -a "$LOGFILE"
  fi
fi

# Send log file
if ! $DRY_RUN; then
  send_discord_file "$LOGFILE"
fi

exit 0
