#!/usr/bin/env bash

# Install command-line tools using Homebrew.

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Configuration variables should be passed via environment from install.sh
# If running standalone, load config
if [[ -z "${PLATFORM:-}" ]]; then
  source "$SCRIPT_DIR/config/default.conf"
  source "$SCRIPT_DIR/config/packages.conf" 2>/dev/null || true
  PLATFORM=$(detect_platform)
fi

# Only run on macOS or if Homebrew is available
if [[ "$PLATFORM" != "darwin" ]] && ! command_exists brew; then
  log_error "This script requires macOS or Homebrew"
  exit 1
fi

log_info "Starting package installation via Homebrew"

# Make sure we're using the latest Homebrew.
log_info "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae.
log_info "Upgrading existing packages..."
brew upgrade

# Save Homebrew's installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities
# On macOS: Install GNU versions (macOS has BSD versions)
# On Linux: Skip (already have GNU versions from system)
if [[ "$PLATFORM" == "darwin" ]]; then
  log_info "Installing GNU core utilities (macOS needs these)..."
  brew install coreutils

  # Create symlink for sha256sum (idempotent)
  if [[ ! -L "${BREW_PREFIX}/bin/sha256sum" ]]; then
    ln -sf "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"
  fi

  # Install GNU tools if enabled
  if [[ "${INSTALL_GNU_TOOLS:-true}" == true ]]; then
    log_info "Installing GNU utilities..."
    brew install moreutils findutils gnu-sed
  fi
else
  log_info "Skipping GNU tools on Linux (already installed via $PACKAGE_MANAGER)"
fi

# Install Bash 4 and modern CLI tools
if [[ "${INSTALL_MODERN_CLI:-true}" == true ]]; then
  log_info "Installing modern CLI tools..."
  brew install bash bash-completion2 fzf bat eza fd zoxide
else
  log_info "Skipping modern CLI tools (INSTALL_MODERN_CLI=false)"
fi

# Install wget with IRI support
brew install wget

# Install GnuPG to enable PGP-signing commits
if [[ "${INSTALL_GIT_TOOLS:-true}" == true ]]; then
  log_info "Installing GnuPG for PGP-signing..."
  brew install gnupg
fi

# Install more recent versions of some macOS tools
# On Linux, skip tools that come from system package manager
if [[ "$PLATFORM" == "darwin" ]]; then
  log_info "Installing updated macOS tools..."
  brew install vim grep screen php gmp
else
  log_info "Installing development runtimes (PHP, etc.)..."
  # On Linux, still install PHP, GMP via Homebrew for consistency
  brew install php gmp
  # vim, grep, screen already installed via pacman
fi

# Install font tools
log_info "Installing font tools..."
brew tap bramstein/webfonttools
brew install sfnt2woff sfnt2woff-zopfli woff2 || log_warning "Some font tools failed to install"

# Install Deskflow (optional KVM software - currently has broken cask)
if [[ "${INSTALL_DESKFLOW:-false}" == true ]]; then
  log_info "Installing Deskflow..."
  brew tap deskflow/homebrew-tap
  brew install deskflow || log_warning "Failed to install Deskflow"
else
  log_info "Skipping Deskflow (INSTALL_DESKFLOW=false)"
fi

# Install CTF tools if enabled
if [[ "${INSTALL_CTF_TOOLS:-false}" == true ]]; then
  log_info "Installing CTF/security tools..."

  if [[ -n "${CTF_PACKAGES:-}" ]]; then
    # Use packages from config if available
    for package in "${CTF_PACKAGES[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  else
    # Fallback to hardcoded list if config not loaded
    ctfs=(
      aircrack-ng binutils binwalk cifer dex2jar dns2tcp
      fcrackzip foremost hydra john knock netpbm nmap
      pngcheck socat sqlmap tcpflow tcpreplay ucspi-tcp xpdf xz
    )
    for package in "${ctfs[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  fi
else
  log_info "Skipping CTF tools (INSTALL_CTF_TOOLS=false)"
fi

# Install development tools if enabled
if [[ "${INSTALL_DEV_TOOLS:-true}" == true ]]; then
  log_info "Installing development tools..."

  if [[ -n "${DEV_PACKAGES:-}" ]]; then
    # Use packages from config
    for package in "${DEV_PACKAGES[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  else
    # Fallback list
    if [[ "$PLATFORM" == "darwin" ]]; then
      bins=(
        python asciinema agg git git-lfs gh git-delta imagemagick
        ack lua lynx p7zip pigz pv rename rlwrap ssh-copy-id
        tree vbindiff htop ansible orbstack asdf
      )
    else
      # Linux: skip system tools (tree, htop) and macOS-only (orbstack)
      bins=(
        python asciinema agg git git-lfs gh git-delta imagemagick
        ack lua lynx p7zip pigz pv rename rlwrap ssh-copy-id
        vbindiff ansible asdf
      )
    fi
    for package in "${bins[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  fi

  # Install terminal recording tools
  if [[ -n "${TERMINAL_RECORDING:-}" ]]; then
    for package in "${TERMINAL_RECORDING[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  fi
fi

# Install Git tools if enabled
if [[ "${INSTALL_GIT_TOOLS:-true}" == true ]]; then
  log_info "Installing Git tools..."
  if [[ -n "${GIT_PACKAGES:-}" ]]; then
    for package in "${GIT_PACKAGES[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  fi
fi

# Install LLM applications if enabled
if [[ "${INSTALL_LLM_APPS:-true}" == true ]]; then
  log_info "Installing LLM applications..."
  if [[ -n "${LLM_APPS:-}" ]]; then
    for package in "${LLM_APPS[@]}"; do
      log_info "Installing $package..."
      brew install "$package" || log_warning "Failed to install $package"
    done
  else
    brew install gemini-cli || log_warning "Failed to install gemini-cli"
  fi
fi

# Install Nerd Fonts
log_info "Installing Nerd Fonts..."
brew install --cask font-0xproto-nerd-font || log_warning "Failed to install Nerd Font"

# Install GUI applications if enabled (macOS only)
if [[ "${INSTALL_APPLICATIONS:-true}" == true ]]; then
  if [[ "$PLATFORM" == "darwin" ]]; then
    log_info "Installing GUI applications..."

    if [[ -n "${PRODUCTIVITY_APPS:-}" ]] || [[ -n "${DEV_APPS:-}" ]]; then
      # Combine productivity and dev apps
      all_apps=()
      [[ -n "${PRODUCTIVITY_APPS:-}" ]] && all_apps+=("${PRODUCTIVITY_APPS[@]}")
      [[ -n "${DEV_APPS:-}" ]] && all_apps+=("${DEV_APPS[@]}")

      for app in "${all_apps[@]}"; do
        log_info "Installing $app..."
        brew install --cask --appdir="/Applications" "$app" || log_warning "Failed to install $app"
      done
    else
      # Fallback to hardcoded list
      apps=(
        firefox firefox@nightly ungoogled-chromium iterm2 keepingyouawake
        keka keycastr macdown slack sourcetree transmission vagrant
        virtualbox vscodium zed zen vlc cron raycast datagrip
        linear-linear bitwarden shottr background-music rectangle
        PlayCover/playcover/playcover-community
      )

      for app in "${apps[@]}"; do
        log_info "Installing $app..."
        brew install --cask --appdir="/Applications" "$app" || log_warning "Failed to install $app"
      done
    fi

    # Quick Look Plugins (macOS Sequoia compatible)
    log_info "Installing Quick Look plugins..."
    brew install suspicious-package apparency qlvideo || log_warning "Some Quick Look plugins failed"
    brew install --no-quarantine glance-chamburr || log_warning "Failed to install Glance"
  else
    log_info "Skipping Homebrew GUI applications on Linux (handled by Phase 4 via $PACKAGE_MANAGER)"
  fi
else
  log_info "Skipping GUI applications (INSTALL_APPLICATIONS=false)"
fi

# Cleanup: Gemini installs node as dependency, but we manage node via Volta
if command_exists gemini && command_exists node; then
  log_info "Removing Homebrew-installed node (managed by Volta)..."
  brew uninstall --ignore-dependencies node 2>/dev/null || true
fi

# Remove outdated versions from the cellar
log_info "Cleaning up old package versions..."
brew cleanup

log_success "Package installation complete!"
