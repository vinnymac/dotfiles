#!/usr/bin/env bash

# install.sh — Shell software installation script
# Created by vinnymac (https://github.com/vinnymac/dotfiles)

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Source library files
DOTFILES_DIR="$(pwd)"
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/error_handler.sh"
source "$DOTFILES_DIR/lib/package_manager.sh"
source "$DOTFILES_DIR/lib/interactive.sh"
source "$DOTFILES_DIR/lib/shell_config.sh"
source "$DOTFILES_DIR/lib/system_packages.sh"

# Initialize logging
init_logging

echo "Shell installation script for vinnymac's dotfiles"
echo "-------------------------------------------------"
echo ""

# Ensure not running as root
ensure_not_root

# Parse command-line arguments
INTERACTIVE_MODE=false
FORCE_MODE=false
DRY_RUN=false
CONFIG_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --interactive|-i)
      INTERACTIVE_MODE=true
      shift
      ;;
    --force|-f)
      FORCE_MODE=true
      shift
      ;;
    --dry-run|-d)
      DRY_RUN=true
      shift
      ;;
    --config|-c)
      CONFIG_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -i, --interactive    Run in interactive mode (choose components)"
      echo "  -f, --force          Run without prompting (use default config)"
      echo "  -d, --dry-run        Show what would be installed without making changes"
      echo "  -c, --config FILE    Use custom configuration file"
      echo "  -h, --help           Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 --interactive     # Interactive mode (recommended for first run)"
      echo "  $0 --force           # Automated mode (uses defaults)"
      echo "  $0 --dry-run         # Preview what would be installed"
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      echo "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac
done

# Detect platform and distribution
PLATFORM=$(detect_platform)
log_info "Detected platform: $PLATFORM"

if [[ "$PLATFORM" == "linux" ]]; then
  DISTRO=$(detect_distro)
  log_info "Detected distribution: $DISTRO"
else
  DISTRO=""
fi

PACKAGE_MANAGER=$(detect_package_manager "$PLATFORM" "$DISTRO")
log_info "Package manager: $PACKAGE_MANAGER"
echo ""

# Load configuration
if [[ -n "$CONFIG_FILE" ]]; then
  if [[ -f "$CONFIG_FILE" ]]; then
    log_info "Loading configuration from: $CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
  fi
elif [[ -f "$DOTFILES_DIR/config/user.conf" ]]; then
  log_info "Loading user configuration..."
  source "$DOTFILES_DIR/config/default.conf"
  source "$DOTFILES_DIR/config/user.conf"
elif [[ -f "$DOTFILES_DIR/config/default.conf" ]]; then
  log_info "Loading default configuration..."
  source "$DOTFILES_DIR/config/default.conf"
else
  log_error "No configuration file found"
  exit 1
fi

# Load package definitions
if [[ -f "$DOTFILES_DIR/config/packages.conf" ]]; then
  source "$DOTFILES_DIR/config/packages.conf"
fi

# Export platform variables for use in other scripts
export PLATFORM
export DISTRO
export PACKAGE_MANAGER

# Run interactive setup if requested
if [[ "$INTERACTIVE_MODE" == true ]]; then
  run_interactive_setup
fi

# Dry run mode - show what would be installed
if [[ "$DRY_RUN" == true ]]; then
  log_info "DRY RUN MODE - No changes will be made"
  echo ""
  log_info "Would install the following components:"
  [[ "$INSTALL_PACKAGE_MANAGER" == true ]] && echo "  ✓ Package Manager ($PACKAGE_MANAGER)"
  [[ "$INSTALL_DEV_TOOLS" == true ]] && echo "  ✓ Development Tools"
  [[ "$INSTALL_MODERN_CLI" == true ]] && echo "  ✓ Modern CLI Tools (fzf, bat, eza, etc.)"
  [[ "$INSTALL_APPLICATIONS" == true ]] && echo "  ✓ GUI Applications"
  [[ "$INSTALL_NODE_TOOLS" == true ]] && echo "  ✓ Node.js Tools (Volta)"
  [[ "$INSTALL_AWS_CLI" == true ]] && echo "  ✓ AWS CLI"
  [[ "$INSTALL_CTF_TOOLS" == true ]] && echo "  ✓ CTF/Security Tools"
  [[ "$INSTALL_LLM_APPS" == true ]] && echo "  ✓ LLM Applications"
  [[ "$SYNC_DOTFILES" == true ]] && echo "  ✓ Sync Dotfiles"
  [[ "$PLATFORM" == "darwin" && "$INSTALL_XCODE" == true ]] && echo "  ✓ Xcode"
  [[ "$PLATFORM" == "darwin" && "$INSTALL_ANDROID_TOOLS" == true ]] && echo "  ✓ Android Tools"
  [[ "$PLATFORM" == "darwin" && "$APPLY_MACOS_SETTINGS" == true ]] && echo "  ✓ macOS Settings"
  echo ""
  echo "Shell: $PREFERRED_SHELL"
  echo ""
  log_success "Dry run complete. Run without --dry-run to actually install."
  exit 0
fi

# Confirmation prompt (unless force mode or interactive mode was used)
if [[ "$FORCE_MODE" == false && "$INTERACTIVE_MODE" == false ]]; then
  log_warning "This will install software and may overwrite files in your home directory."
  if ! ask_yes_no "Do you want to continue?" "n"; then
    log_info "Installation cancelled"
    exit 0
  fi
  echo ""
fi

# Main installation function
doInstallation() {
  # Phase 1-5: Install system packages via native package manager (Linux only)
  if [[ "$PLATFORM" == "linux" ]]; then
    echo "========================================"
    log_info "Installing system packages via $PACKAGE_MANAGER"
    echo "========================================"
    echo ""

    # Phase 1: System prerequisites (critical)
    log_info "[Phase 1/5] Installing system prerequisites..."
    install_system_prerequisites "$DISTRO" "$PACKAGE_MANAGER" || {
      log_error "Failed to install system prerequisites"
      record_error "system_prereqs" "Failed to install system prerequisites"
      return 1
    }
    echo ""

    # Phase 2: Common utilities
    log_info "[Phase 2/5] Installing common utilities..."
    install_system_utilities "$DISTRO" "$PACKAGE_MANAGER" || {
      log_warning "Some utilities failed to install (non-critical)"
    }
    echo ""

    # Phase 3: GNU tools and system libraries
    log_info "[Phase 3/5] Installing GNU tools and system libraries..."
    install_gnu_tools_and_libs "$DISTRO" "$PACKAGE_MANAGER" || {
      log_warning "Some GNU tools failed to install (non-critical)"
    }
    echo ""

    # Phase 4: GUI applications (if enabled)
    if [[ "${INSTALL_APPLICATIONS:-true}" == true ]]; then
      log_info "[Phase 4/5] Installing GUI applications..."
      install_gui_applications "$DISTRO" "$PACKAGE_MANAGER" || {
        log_warning "Some GUI applications failed to install (non-critical)"
      }
      echo ""

      # Phase 5: AUR packages (Arch only)
      if [[ "$DISTRO" == "arch" ]]; then
        log_info "[Phase 5/5] Installing AUR packages..."
        install_aur_packages "$DISTRO" || {
          log_warning "Some AUR packages failed to install (non-critical)"
        }
        echo ""
      else
        log_info "[Phase 5/5] Skipping AUR packages (not on Arch Linux)"
        echo ""
      fi
    else
      log_info "[Phase 4/5] Skipping GUI applications (INSTALL_APPLICATIONS=false)"
      log_info "[Phase 5/5] Skipping AUR packages (INSTALL_APPLICATIONS=false)"
      echo ""
    fi

    log_success "System package installation complete!"
    echo ""
  fi

  # Install package manager
  if [[ "$INSTALL_PACKAGE_MANAGER" == true ]]; then
    log_info "Setting up package manager..."
    install_package_manager "$PLATFORM" "$DISTRO" || record_error "package_manager" "Failed to install package manager"
  fi

  # Update package manager
  if [[ "$INSTALL_PACKAGE_MANAGER" == true ]]; then
    pkg_update || record_error "package_manager" "Failed to update package manager"
  fi

  # Install packages via brew.sh or equivalent
  if [[ "$INSTALL_DEV_TOOLS" == true || "$INSTALL_APPLICATIONS" == true ]]; then
    log_info "Installing packages..."
    /bin/bash "$DOTFILES_DIR/brew.sh" || record_error "brew" "Package installation had errors"
  fi

  # Setup asdf version manager
  if [[ "$INSTALL_DEV_TOOLS" == true ]]; then
    setupAsdf || record_error "asdf" "Failed to setup asdf"
  fi

  # Install Volta for Node.js
  if [[ "$INSTALL_NODE_TOOLS" == true ]]; then
    installVolta || record_error "volta" "Failed to install Volta/Node.js"
  fi

  # Install AWS CLI
  if [[ "$INSTALL_AWS_CLI" == true ]]; then
    /bin/bash "$DOTFILES_DIR/aws2.sh" || record_error "aws" "Failed to install AWS CLI"
  fi

  # Install Android tools (macOS only)
  if [[ "$PLATFORM" == "darwin" && "$INSTALL_ANDROID_TOOLS" == true ]]; then
    /bin/bash "$DOTFILES_DIR/android.sh" || record_error "android" "Failed to install Android tools"
  fi

  # Install Xcode (macOS only)
  if [[ "$PLATFORM" == "darwin" && "$INSTALL_XCODE" == true ]]; then
    /bin/bash "$DOTFILES_DIR/xcode.sh" || record_error "xcode" "Failed to install Xcode"
  fi

  # Sync dotfiles
  if [[ "$SYNC_DOTFILES" == true ]]; then
    syncConfig || record_error "sync" "Failed to sync dotfiles"
  fi

  # Setup shell configuration
  setup_shell "$PREFERRED_SHELL" || record_error "shell" "Failed to setup shell"

  # Apply macOS settings (macOS only)
  if [[ "$PLATFORM" == "darwin" && "$APPLY_MACOS_SETTINGS" == true ]]; then
    macOsConfig || record_error "macos" "Failed to apply macOS settings"
  fi
}

setupAsdf() {
  if ! command_exists asdf; then
    log_warning "asdf not installed, skipping asdf setup"
    return 0
  fi

  log_info "Setting up asdf..."

  # Source asdf
  if [[ "$PLATFORM" == "darwin" ]]; then
    source "$(brew --prefix asdf)/libexec/asdf.sh"
  elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    source "$HOME/.asdf/asdf.sh"
  fi

  # Install useful plugins
  log_info "Installing asdf plugins..."
  asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git 2>/dev/null || true
  asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git 2>/dev/null || true
  asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git 2>/dev/null || true
  asdf plugin add terraform https://github.com/Banno/asdf-hashicorp.git 2>/dev/null || true
  asdf plugin add packer https://github.com/Banno/asdf-hashicorp.git 2>/dev/null || true

  # Install versions from .tool-versions if it exists
  if [[ -f "$DOTFILES_DIR/.tool-versions" ]]; then
    log_info "Installing tools from .tool-versions..."
    asdf install
  fi

  log_success "asdf setup complete"
}

installVolta() {
  if ! command_exists volta; then
    log_info "Installing Volta..."
    if command_exists brew; then
      brew install volta
    else
      curl https://get.volta.sh | bash
    fi
  fi

  # Setup volta (this adds it to PATH)
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"

  log_info "Installing Node.js via Volta..."
  volta install node@22 || log_warning "Failed to install Node.js 22"
  volta install yarn@4 || log_warning "Failed to install Yarn 4"

  # Verify installation
  if command_exists node; then
    log_success "Node.js $(node --version) installed"
  fi
  if command_exists yarn; then
    log_success "Yarn $(yarn --version) installed"
  fi
}

syncConfig() {
  log_info "Syncing configuration files..."

  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".macos" \
    --exclude "README.md" \
    --exclude "LICENSE.md" \
    --exclude "node.sh" \
    --exclude "brew.sh" \
    --exclude "install.sh" \
    --exclude "aws2.sh" \
    --exclude "aws2ForM1.sh" \
    --exclude "xcode.sh" \
    --exclude "android.sh" \
    --exclude "iTerm2_default.json" \
    --exclude "lib/" \
    --exclude "config/" \
    --exclude "docs/" \
    --exclude ".claude/" \
    -avh --no-perms . ~

  # Symlink config files that should stay in sync with the repo
  mkdir -p "$HOME/.claude"
  ln -sf "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

  log_success "Configuration files synced"
}

macOsConfig() {
  log_info "Applying macOS system settings..."
  /bin/bash "$DOTFILES_DIR/.macos"
  log_success "macOS settings applied"
}

# Run the installation
doInstallation

# Show error summary
echo ""
show_error_summary

# Cleanup if successful
if [[ ${#INSTALLATION_ERRORS[@]} -eq 0 ]]; then
  cleanup_log
fi

echo ""
log_info "Installation complete!"
log_warning "You may need to restart your terminal or log out for all changes to take effect."

exit 0
