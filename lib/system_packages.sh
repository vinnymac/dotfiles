#!/usr/bin/env bash
# System package installation for native package managers
# This handles OS-level packages that should NOT come from Homebrew

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# System prerequisites by distribution (Phase 1 - Critical)
declare -A SYSTEM_PREREQS=(
  # Arch Linux (linux-headers needed for virtualbox and other DKMS modules)
  ["arch"]="base-devel linux-headers zsh rsync git curl wget vim which sudo"

  # Debian/Ubuntu
  ["debian"]="build-essential linux-headers-generic zsh rsync git curl wget vim sudo"
  ["ubuntu"]="build-essential linux-headers-generic zsh rsync git curl wget vim sudo"

  # Fedora/RHEL
  ["fedora"]="@development-tools kernel-devel zsh rsync git curl wget vim which sudo"
  ["rhel"]="@development-tools kernel-devel zsh rsync git curl wget vim which sudo"
  ["centos"]="@development-tools kernel-devel zsh rsync git curl wget vim which sudo"
)

# Phase 2: Common utilities (faster, lighter than Homebrew)
declare -A SYSTEM_UTILITIES=(
  # Arch Linux
  ["arch"]="htop tree tmux screen unzip zip p7zip tar man-db less"

  # Debian/Ubuntu
  ["debian"]="htop tree tmux screen unzip zip p7zip-full tar man-db less"
  ["ubuntu"]="htop tree tmux screen unzip zip p7zip-full tar man-db less"

  # Fedora/RHEL
  ["fedora"]="htop tree tmux screen unzip zip p7zip tar man-db less"
  ["rhel"]="htop tree tmux screen unzip zip p7zip tar man-db less"
  ["centos"]="htop tree tmux screen unzip zip p7zip tar man-db less"
)

# Phase 3: GNU tools and system libraries
# On Linux, these are already GNU versions or system-provided
declare -A SYSTEM_GNU_LIBS=(
  # Arch Linux - already has GNU versions of coreutils, sed, grep
  # Just ensure they're installed
  ["arch"]="coreutils sed grep gawk findutils openssl sqlite"

  # Debian/Ubuntu
  ["debian"]="coreutils sed grep gawk findutils openssl libsqlite3-0"
  ["ubuntu"]="coreutils sed grep gawk findutils openssl libsqlite3-0"

  # Fedora/RHEL
  ["fedora"]="coreutils sed grep gawk findutils openssl sqlite"
  ["rhel"]="coreutils sed grep gawk findutils openssl sqlite"
  ["centos"]="coreutils sed grep gawk findutils openssl sqlite"
)

# Phase 4: GUI Applications (Linux equivalents of macOS apps)
# Only applications available in official repositories
declare -A SYSTEM_GUI_APPS=(
  # Arch Linux
  ["arch"]="firefox bitwarden vlc transmission-gtk virtualbox"

  # Debian/Ubuntu
  ["debian"]="firefox-esr bitwarden vlc transmission-gtk virtualbox"
  ["ubuntu"]="firefox bitwarden vlc transmission-gtk virtualbox"

  # Fedora/RHEL
  ["fedora"]="firefox bitwarden vlc transmission-gtk virtualbox"
  ["rhel"]="firefox bitwarden vlc transmission-gtk"
  ["centos"]="firefox vlc transmission-gtk"
)

# Phase 5: AUR Packages (Arch User Repository)
# These require an AUR helper (yay, paru, etc.)
declare -A AUR_PACKAGES=(
  # Arch Linux - packages only available in AUR
  ["arch"]="slack-desktop vscodium-bin"

  # Other distros don't use AUR
  ["debian"]=""
  ["ubuntu"]=""
  ["fedora"]=""
  ["rhel"]=""
  ["centos"]=""
)

# Check if we can run sudo commands
check_sudo_access() {
  if sudo -n true 2>/dev/null; then
    log_info "sudo access: Cached ✓"
    return 0
  elif sudo -v 2>/dev/null; then
    log_info "sudo access: Available (prompted) ✓"
    return 0
  else
    log_error "sudo access: Not available ✗"
    return 1
  fi
}

# Install system prerequisites using native package manager
install_system_prerequisites() {
  local distro="$1"
  local package_manager="$2"

  log_info "Installing system prerequisites for $distro..."

  # Get prerequisite list for this distro
  local prereq_list="${SYSTEM_PREREQS[$distro]:-}"

  if [[ -z "$prereq_list" ]]; then
    log_warning "No system prerequisites defined for $distro"
    return 0
  fi

  # Convert space-separated string to array
  local -a prereqs
  read -ra prereqs <<< "$prereq_list"

  log_info "Will install ${#prereqs[@]} system packages: ${prereqs[*]}"

  # Check sudo access before attempting installation
  if ! check_sudo_access; then
    log_error "Cannot install system packages without sudo access"
    return 1
  fi

  # Install based on package manager
  case "$package_manager" in
    pacman)
      log_info "Using pacman to install system packages..."
      # Update package database
      sudo pacman -Sy || log_warning "Failed to update pacman database"

      # Install packages (--needed = skip already installed)
      sudo pacman -S --needed --noconfirm "${prereqs[@]}" || {
        log_error "Failed to install some system packages"
        return 1
      }
      ;;

    apt)
      log_info "Using apt to install system packages..."
      # Update package lists
      sudo apt-get update || log_warning "Failed to update apt cache"

      # Install packages
      sudo apt-get install -y "${prereqs[@]}" || {
        log_error "Failed to install some system packages"
        return 1
      }
      ;;

    dnf)
      log_info "Using dnf to install system packages..."
      # Install packages (dnf handles groups with @ prefix automatically)
      sudo dnf install -y "${prereqs[@]}" || {
        log_error "Failed to install some system packages"
        return 1
      }
      ;;

    yum)
      log_info "Using yum to install system packages..."
      # Install packages
      sudo yum install -y "${prereqs[@]}" || {
        log_error "Failed to install some system packages"
        return 1
      }
      ;;

    brew)
      log_info "Skipping system prerequisites on macOS (Homebrew handles everything)"
      return 0
      ;;

    *)
      log_error "Unsupported package manager for system prerequisites: $package_manager"
      return 1
      ;;
  esac

  log_success "System prerequisites installed successfully"

  # Verify critical packages
  verify_prerequisites
}

# Verify that critical prerequisites are available
verify_prerequisites() {
  local -a critical=(zsh git curl)
  local missing=()

  for cmd in "${critical[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    log_error "Critical prerequisites missing: ${missing[*]}"
    return 1
  fi

  log_info "Critical prerequisites verified: zsh=$(which zsh), git=$(git --version | head -1)"
  return 0
}

# Phase 2: Install common utilities
install_system_utilities() {
  local distro="$1"
  local package_manager="$2"

  log_info "Phase 2: Installing common utilities..."

  # Get utility list for this distro
  local util_list="${SYSTEM_UTILITIES[$distro]:-}"

  if [[ -z "$util_list" ]]; then
    log_warning "No system utilities defined for $distro"
    return 0
  fi

  # Convert space-separated string to array
  local -a utils
  read -ra utils <<< "$util_list"

  log_info "Installing ${#utils[@]} common utilities via $package_manager..."

  # Install based on package manager
  case "$package_manager" in
    pacman)
      sudo pacman -S --needed --noconfirm "${utils[@]}" || {
        log_warning "Some utilities failed to install (non-critical)"
        return 0
      }
      ;;

    apt)
      sudo apt-get install -y "${utils[@]}" || {
        log_warning "Some utilities failed to install (non-critical)"
        return 0
      }
      ;;

    dnf|yum)
      sudo "$package_manager" install -y "${utils[@]}" || {
        log_warning "Some utilities failed to install (non-critical)"
        return 0
      }
      ;;

    brew)
      log_info "Skipping system utilities on macOS (will use Homebrew)"
      return 0
      ;;

    *)
      log_warning "Unsupported package manager for utilities: $package_manager"
      return 0
      ;;
  esac

  log_success "Common utilities installed"
  return 0
}

# Phase 3: Install GNU tools and system libraries
# On Linux, these are often already present as GNU versions
install_gnu_tools_and_libs() {
  local distro="$1"
  local package_manager="$2"

  log_info "Phase 3: Installing GNU tools and system libraries..."

  # Get GNU/lib list for this distro
  local gnu_list="${SYSTEM_GNU_LIBS[$distro]:-}"

  if [[ -z "$gnu_list" ]]; then
    log_warning "No GNU tools/libs defined for $distro"
    return 0
  fi

  # Convert space-separated string to array
  local -a gnu_tools
  read -ra gnu_tools <<< "$gnu_list"

  log_info "Installing ${#gnu_tools[@]} GNU tools and libraries via $package_manager..."

  # Install based on package manager
  case "$package_manager" in
    pacman)
      sudo pacman -S --needed --noconfirm "${gnu_tools[@]}" || {
        log_warning "Some GNU tools failed to install (non-critical)"
        return 0
      }
      ;;

    apt)
      sudo apt-get install -y "${gnu_tools[@]}" || {
        log_warning "Some GNU tools failed to install (non-critical)"
        return 0
      }
      ;;

    dnf|yum)
      sudo "$package_manager" install -y "${gnu_tools[@]}" || {
        log_warning "Some GNU tools failed to install (non-critical)"
        return 0
      }
      ;;

    brew)
      log_info "Skipping GNU tools on macOS (will install via Homebrew)"
      return 0
      ;;

    *)
      log_warning "Unsupported package manager for GNU tools: $package_manager"
      return 0
      ;;
  esac

  log_success "GNU tools and libraries installed"
  return 0
}

# Phase 4: Install GUI applications
install_gui_applications() {
  local distro="$1"
  local package_manager="$2"

  log_info "Phase 4: Installing GUI applications..."

  # Get GUI app list for this distro
  local app_list="${SYSTEM_GUI_APPS[$distro]:-}"

  if [[ -z "$app_list" ]]; then
    log_warning "No GUI applications defined for $distro"
    return 0
  fi

  # Convert space-separated string to array
  local -a apps
  read -ra apps <<< "$app_list"

  log_info "Installing ${#apps[@]} GUI applications via $package_manager..."

  # Install based on package manager
  case "$package_manager" in
    pacman)
      sudo pacman -S --needed --noconfirm "${apps[@]}" || {
        log_warning "Some GUI applications failed to install (non-critical)"
        return 0
      }
      ;;

    apt)
      sudo apt-get install -y "${apps[@]}" || {
        log_warning "Some GUI applications failed to install (non-critical)"
        return 0
      }
      ;;

    dnf|yum)
      sudo "$package_manager" install -y "${apps[@]}" || {
        log_warning "Some GUI applications failed to install (non-critical)"
        return 0
      }
      ;;

    brew)
      log_info "Skipping system GUI apps on macOS (will use Homebrew casks)"
      return 0
      ;;

    *)
      log_warning "Unsupported package manager for GUI apps: $package_manager"
      return 0
      ;;
  esac

  log_success "GUI applications installed"
  return 0
}

# Check if an AUR helper is installed
check_aur_helper() {
  if command -v yay &>/dev/null; then
    echo "yay"
    return 0
  elif command -v paru &>/dev/null; then
    echo "paru"
    return 0
  elif command -v pikaur &>/dev/null; then
    echo "pikaur"
    return 0
  else
    return 1
  fi
}

# Install yay AUR helper
install_yay() {
  log_info "Installing yay AUR helper..."

  # Check if already installed
  if command -v yay &>/dev/null; then
    log_info "yay already installed"
    return 0
  fi

  # Install dependencies
  sudo pacman -S --needed --noconfirm base-devel git || {
    log_error "Failed to install yay dependencies"
    return 1
  }

  # Save current directory to return to it later
  local original_dir="$PWD"

  # Clone and build yay
  local tmp_dir="/tmp/yay-install-$$"
  mkdir -p "$tmp_dir"
  cd "$tmp_dir" || return 1

  git clone https://aur.archlinux.org/yay.git || {
    log_error "Failed to clone yay repository"
    cd "$original_dir" || true
    rm -rf "$tmp_dir"
    return 1
  }

  cd yay || return 1
  makepkg -si --noconfirm || {
    log_error "Failed to build yay"
    cd "$original_dir" || true
    rm -rf "$tmp_dir"
    return 1
  }

  # Return to original directory before removing temp directory
  cd "$original_dir" || true
  rm -rf "$tmp_dir"

  log_success "yay AUR helper installed"
  return 0
}

# Phase 5: Install AUR packages (Arch only)
install_aur_packages() {
  local distro="$1"

  # Only applicable to Arch Linux
  if [[ "$distro" != "arch" ]]; then
    return 0
  fi

  log_info "Phase 5: Installing AUR packages..."

  # Get AUR package list
  local aur_list="${AUR_PACKAGES[$distro]:-}"

  if [[ -z "$aur_list" ]]; then
    log_info "No AUR packages defined for $distro"
    return 0
  fi

  # Check for AUR helper
  local aur_helper
  if ! aur_helper=$(check_aur_helper); then
    log_warning "No AUR helper found (yay, paru, pikaur)"
    log_info "Attempting to install yay..."

    if ! install_yay; then
      log_warning "Failed to install AUR helper - skipping AUR packages"
      log_info "You can manually install yay and then run: yay -S $aur_list"
      return 0
    fi

    aur_helper="yay"
  fi

  log_info "Using AUR helper: $aur_helper"

  # Convert space-separated string to array
  local -a aur_pkgs
  read -ra aur_pkgs <<< "$aur_list"

  log_info "Installing ${#aur_pkgs[@]} AUR packages..."

  # Install AUR packages (no sudo needed with AUR helpers)
  for pkg in "${aur_pkgs[@]}"; do
    log_info "Installing $pkg from AUR..."
    $aur_helper -S --needed --noconfirm "$pkg" || {
      log_warning "Failed to install $pkg from AUR (non-critical)"
    }
  done

  log_success "AUR packages installation complete"
  return 0
}

# Export functions for use in install.sh
export -f check_sudo_access
export -f install_system_prerequisites
export -f verify_prerequisites
export -f install_system_utilities
export -f install_gnu_tools_and_libs
export -f install_gui_applications
export -f check_aur_helper
export -f install_yay
export -f install_aur_packages
