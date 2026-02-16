#!/usr/bin/env bash
# Interactive prompts for installation options

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Interactive mode - asks user what to install
run_interactive_setup() {
  log_info "Starting interactive setup..."
  echo

  # Shell selection
  select_shell

  # Component selection
  select_components

  # Package categories
  select_package_categories

  # Platform-specific options
  select_platform_options

  # Confirm choices
  confirm_selections
}

select_shell() {
  log_info "Which shell would you like to use?"
  echo "  1) bash (Bourne Again Shell)"
  echo "  2) zsh (Z Shell - more features, modern default on macOS)"

  local choice
  read -p "Enter choice [1-2]: " choice

  case "$choice" in
    1) PREFERRED_SHELL="bash" ;;
    2) PREFERRED_SHELL="zsh" ;;
    *)
      log_warning "Invalid choice, defaulting to bash"
      PREFERRED_SHELL="bash"
      ;;
  esac

  log_success "Selected shell: $PREFERRED_SHELL"
  echo
}

select_components() {
  log_info "Select components to install:"
  echo

  ask_yes_no "Install/update package manager (Homebrew/apt/dnf)?" "y" && \
    INSTALL_PACKAGE_MANAGER=true || INSTALL_PACKAGE_MANAGER=false

  ask_yes_no "Install development tools (git, vim, asdf, etc.)?" "y" && \
    INSTALL_DEV_TOOLS=true || INSTALL_DEV_TOOLS=false

  ask_yes_no "Install modern CLI tools (fzf, bat, eza, zoxide)?" "y" && \
    INSTALL_MODERN_CLI=true || INSTALL_MODERN_CLI=false

  ask_yes_no "Install GUI applications (browsers, editors, etc.)?" "y" && \
    INSTALL_APPLICATIONS=true || INSTALL_APPLICATIONS=false

  ask_yes_no "Install Node.js tools (via Volta)?" "y" && \
    INSTALL_NODE_TOOLS=true || INSTALL_NODE_TOOLS=false

  ask_yes_no "Install AWS CLI?" "n" && \
    INSTALL_AWS_CLI=true || INSTALL_AWS_CLI=false

  ask_yes_no "Sync dotfiles to home directory?" "y" && \
    SYNC_DOTFILES=true || SYNC_DOTFILES=false

  echo
}

select_package_categories() {
  log_info "Select additional package categories:"
  echo

  ask_yes_no "Install CTF/security tools?" "n" && \
    INSTALL_CTF_TOOLS=true || INSTALL_CTF_TOOLS=false

  ask_yes_no "Install LLM applications (Claude Code, Codex, etc.)?" "y" && \
    INSTALL_LLM_APPS=true || INSTALL_LLM_APPS=false

  echo
}

select_platform_options() {
  if [[ "$PLATFORM" == "darwin" ]]; then
    select_macos_options
  elif [[ "$PLATFORM" == "linux" ]]; then
    select_linux_options
  fi
}

select_macos_options() {
  log_info "macOS-specific options:"
  echo

  ask_yes_no "Install Xcode and Command Line Tools?" "n" && \
    INSTALL_XCODE=true || INSTALL_XCODE=false

  ask_yes_no "Install Android development tools?" "n" && \
    INSTALL_ANDROID_TOOLS=true || INSTALL_ANDROID_TOOLS=false

  ask_yes_no "Apply macOS system settings (.macos script)?" "y" && \
    APPLY_MACOS_SETTINGS=true || APPLY_MACOS_SETTINGS=false

  echo
}

select_linux_options() {
  log_info "Linux-specific options:"
  echo

  # Future Linux-specific options can go here
  log_info "No additional Linux-specific options at this time"
  echo
}

confirm_selections() {
  log_info "Installation Summary:"
  echo "  Shell: $PREFERRED_SHELL"
  echo "  Package Manager: $INSTALL_PACKAGE_MANAGER"
  echo "  Dev Tools: $INSTALL_DEV_TOOLS"
  echo "  Modern CLI: $INSTALL_MODERN_CLI"
  echo "  GUI Apps: $INSTALL_APPLICATIONS"
  echo "  Node.js: $INSTALL_NODE_TOOLS"
  echo "  AWS CLI: $INSTALL_AWS_CLI"
  echo "  CTF Tools: $INSTALL_CTF_TOOLS"
  echo "  LLM Apps: $INSTALL_LLM_APPS"
  echo "  Sync Dotfiles: $SYNC_DOTFILES"

  if [[ "$PLATFORM" == "darwin" ]]; then
    echo "  Xcode: $INSTALL_XCODE"
    echo "  Android Tools: $INSTALL_ANDROID_TOOLS"
    echo "  macOS Settings: $APPLY_MACOS_SETTINGS"
  fi

  echo

  if ! ask_yes_no "Proceed with installation?" "y"; then
    log_warning "Installation cancelled by user"
    exit 0
  fi

  echo
}
