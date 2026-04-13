#!/usr/bin/env bash
# Utility functions for dotfiles installation

# Prevent double-sourcing
if [[ -n "${DOTFILES_UTILS_LOADED:-}" ]]; then
  return 0
fi
readonly DOTFILES_UTILS_LOADED=true

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Platform detection
detect_platform() {
  case "$(uname -s)" in
    Linux*)   echo "linux" ;;
    Darwin*)  echo "darwin" ;;
    *)        echo "unknown" ;;
  esac
}

# Linux distribution detection
detect_distro() {
  if [[ ! -f /etc/os-release ]]; then
    echo "unknown"
    return
  fi

  source /etc/os-release
  case "$ID" in
    ubuntu|debian|linuxmint)
      echo "debian"
      ;;
    fedora|rhel|centos|rocky|almalinux)
      echo "redhat"
      ;;
    arch|manjaro)
      echo "arch"
      ;;
    *)
      echo "$ID"
      ;;
  esac
}

# Detect package manager
detect_package_manager() {
  local platform="$1"
  local distro="${2:-}"

  if [[ "$platform" == "darwin" ]]; then
    echo "brew"
  elif [[ "$platform" == "linux" ]]; then
    case "$distro" in
      debian)  echo "apt" ;;
      redhat)  echo "dnf" ;;
      arch)    echo "pacman" ;;
      *)       echo "unknown" ;;
    esac
  else
    echo "unknown"
  fi
}

# Ask yes/no question
ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"

  local yn
  if [[ "$default" == "y" ]]; then
    read -p "$prompt [Y/n] " -n 1 -r yn
  else
    read -p "$prompt [y/N] " -n 1 -r yn
  fi
  echo

  [[ -z "$yn" ]] && yn="$default"
  [[ "$yn" =~ ^[Yy]$ ]]
}

# Validate shell choice
validate_shell() {
  local shell="$1"
  case "$shell" in
    bash|zsh) return 0 ;;
    *) return 1 ;;
  esac
}

# Check if running as root
is_root() {
  [[ $EUID -eq 0 ]]
}

# Ensure not running as root
ensure_not_root() {
  if is_root; then
    log_error "This script should not be run as root"
    exit 1
  fi
}

# Backup file if it exists
backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Backing up $file to $backup"
    cp "$file" "$backup"
  fi
}
