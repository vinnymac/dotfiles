#!/usr/bin/env bash
# Error handling and recovery

set -euo pipefail

# Global error tracking
declare -a INSTALLATION_ERRORS=()
INSTALL_LOG_FILE="/tmp/dotfiles-install-$(date +%Y%m%d_%H%M%S).log"

# Initialize logging
init_logging() {
  # Create log file
  touch "$INSTALL_LOG_FILE"

  # Tee output to both console and log file
  exec > >(tee -a "$INSTALL_LOG_FILE")
  exec 2>&1

  log_info "Installation log: $INSTALL_LOG_FILE"
}

# Record error
record_error() {
  local component="$1"
  local error_msg="$2"
  INSTALLATION_ERRORS+=("$component: $error_msg")
}

# Display error summary
show_error_summary() {
  echo ""
  echo "========================================"

  if [[ ${#INSTALLATION_ERRORS[@]} -gt 0 ]]; then
    log_warning "Installation completed with ${#INSTALLATION_ERRORS[@]} errors:"
    for error in "${INSTALLATION_ERRORS[@]}"; do
      log_error "  - $error"
    done
    echo
    log_info "Check log file for details: $INSTALL_LOG_FILE"
    echo "========================================"
    return 1
  else
    log_success "Installation completed successfully!"
    echo "========================================"
    return 0
  fi
}

# Cleanup log file if successful
cleanup_log() {
  if [[ ${#INSTALLATION_ERRORS[@]} -eq 0 ]]; then
    if ask_yes_no "Remove log file (installation was successful)?" "y"; then
      rm -f "$INSTALL_LOG_FILE"
      log_info "Log file removed"
    fi
  fi
}
