#!/usr/bin/env bash
# Package manager abstraction layer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Install package using appropriate package manager
pkg_install() {
  local package="$1"
  local pm="${PACKAGE_MANAGER:-}"

  if [[ -z "$pm" ]]; then
    log_error "Package manager not detected"
    return 1
  fi

  case "$pm" in
    brew)
      brew install "$package"
      ;;
    apt)
      sudo apt-get install -y "$package"
      ;;
    dnf)
      sudo dnf install -y "$package"
      ;;
    pacman)
      sudo pacman -S --noconfirm "$package"
      ;;
    *)
      log_error "Unsupported package manager: $pm"
      return 1
      ;;
  esac
}

# Install packages from array
pkg_install_batch() {
  local -n packages=$1
  local pm="${PACKAGE_MANAGER:-}"

  if [[ -z "$pm" ]]; then
    log_error "Package manager not detected"
    return 1
  fi

  case "$pm" in
    brew)
      for package in "${packages[@]}"; do
        log_info "Installing $package..."
        brew install "$package" || log_warning "Failed to install $package"
      done
      ;;
    apt)
      log_info "Installing ${#packages[@]} packages via apt..."
      sudo apt-get update
      sudo apt-get install -y "${packages[@]}" || log_warning "Some packages failed to install"
      ;;
    dnf)
      log_info "Installing ${#packages[@]} packages via dnf..."
      sudo dnf install -y "${packages[@]}" || log_warning "Some packages failed to install"
      ;;
    pacman)
      log_info "Installing ${#packages[@]} packages via pacman..."
      sudo pacman -S --noconfirm "${packages[@]}" || log_warning "Some packages failed to install"
      ;;
  esac
}

# Install cask (macOS applications)
pkg_install_cask() {
  local package="$1"
  local pm="${PACKAGE_MANAGER:-}"

  if [[ "$pm" != "brew" ]]; then
    log_warning "Cask installation only available on macOS with Homebrew"
    return 1
  fi

  brew install --cask --appdir="/Applications" "$package"
}

# Install casks from array
pkg_install_cask_batch() {
  local -n packages=$1
  local pm="${PACKAGE_MANAGER:-}"

  if [[ "$pm" != "brew" ]]; then
    log_warning "Cask installation only available on macOS with Homebrew, skipping GUI apps"
    return 0
  fi

  for package in "${packages[@]}"; do
    log_info "Installing $package..."
    brew install --cask --appdir="/Applications" "$package" || log_warning "Failed to install $package"
  done
}

# Update package manager
pkg_update() {
  local pm="${PACKAGE_MANAGER:-}"

  case "$pm" in
    brew)
      log_info "Updating Homebrew..."
      brew update
      ;;
    apt)
      log_info "Updating apt..."
      sudo apt-get update
      ;;
    dnf)
      log_info "Updating dnf..."
      sudo dnf check-update || true
      ;;
    pacman)
      log_info "Updating pacman..."
      sudo pacman -Sy
      ;;
  esac
}

# Upgrade installed packages
pkg_upgrade() {
  local pm="${PACKAGE_MANAGER:-}"

  case "$pm" in
    brew)
      log_info "Upgrading Homebrew packages..."
      brew upgrade
      ;;
    apt)
      log_info "Upgrading apt packages..."
      sudo apt-get upgrade -y
      ;;
    dnf)
      log_info "Upgrading dnf packages..."
      sudo dnf upgrade -y
      ;;
    pacman)
      log_info "Upgrading pacman packages..."
      sudo pacman -Su --noconfirm
      ;;
  esac
}

# Check if package manager is installed
pkg_manager_exists() {
  local pm="$1"
  command_exists "$pm"
}

# Install package manager if needed
install_package_manager() {
  local platform="$1"
  local distro="${2:-}"

  case "$platform" in
    darwin)
      if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Set up brew environment
        if [[ "$(uname -p)" == "arm" ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        else
          eval "$(/usr/local/bin/brew shellenv)"
        fi

        log_success "Homebrew installed successfully"
      else
        log_info "Homebrew already installed"
      fi
      ;;
    linux)
      case "$distro" in
        debian)
          if ! command_exists apt-get; then
            log_error "apt-get not found - unexpected for Debian-based system"
            return 1
          fi
          log_info "apt already available"
          ;;
        redhat)
          if ! command_exists dnf; then
            log_warning "dnf not found, checking for yum..."
            if command_exists yum; then
              log_info "Using yum instead of dnf"
              PACKAGE_MANAGER="yum"
            else
              log_error "Neither dnf nor yum found"
              return 1
            fi
          fi
          ;;
        arch)
          if ! command_exists pacman; then
            log_error "pacman not found - unexpected for Arch-based system"
            return 1
          fi
          log_info "pacman already available"
          ;;
        *)
          # Offer to install Homebrew on Linux
          if ask_yes_no "Install Homebrew on Linux?" "n"; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            PACKAGE_MANAGER="brew"
          fi
          ;;
      esac
      ;;
  esac
}
