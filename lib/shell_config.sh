#!/usr/bin/env bash
# Shell configuration management

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Set up shell configuration
setup_shell() {
  local shell="$1"

  case "$shell" in
    bash)
      setup_bash
      ;;
    zsh)
      setup_zsh
      ;;
    *)
      log_error "Unsupported shell: $shell"
      return 1
      ;;
  esac

  # Optionally change default shell
  if ask_yes_no "Set $shell as default shell?" "y"; then
    change_default_shell "$shell"
  fi
}

setup_bash() {
  log_info "Setting up bash configuration..."

  # The .bash_profile already exists and sources dotfiles
  # Just ensure it's properly configured
  if [[ -f "$HOME/.bash_profile" ]]; then
    log_success "Bash configuration already exists"
  else
    log_warning ".bash_profile not found (will be synced from dotfiles)"
  fi
}

setup_zsh() {
  log_info "Setting up zsh configuration..."

  # Create .zshrc if it doesn't exist
  if [[ ! -f "$HOME/.zshrc" ]]; then
    log_info "Creating .zshrc..."
    cat > "$HOME/.zshrc" <<'EOF'
# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don't want to commit.
for file in ~/.{path,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Homebrew shell environment
brew_cmd="/usr/local/bin/brew"
if [[ "$(uname)" == "Darwin" && "$(uname -p)" == "arm" ]]; then
  brew_cmd="/opt/homebrew/bin/brew"
fi
eval "$(${brew_cmd} shellenv)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd for listing path candidates
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
  export | unset) fzf --preview "eval 'echo \${}'" "$@" ;;
  ssh) fzf --preview 'dig {}' "$@" ;;
  *) fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$(brew --prefix python)/libexec/bin:$PATH"
EOF
    log_success "Created .zshrc"
  else
    log_info ".zshrc already exists"
  fi
}

change_default_shell() {
  local shell="$1"
  local shell_path=""

  # Find shell path
  if [[ "$PLATFORM" == "darwin" ]] && command_exists brew; then
    shell_path="$(brew --prefix)/bin/$shell"
  else
    shell_path="$(command -v "$shell")"
  fi

  if [[ -z "$shell_path" ]]; then
    log_error "Could not find $shell"
    return 1
  fi

  # Verify shell exists
  if [[ ! -x "$shell_path" ]]; then
    log_error "Shell not executable: $shell_path"
    return 1
  fi

  # Add to /etc/shells if not present
  if ! grep -q "^$shell_path$" /etc/shells 2>/dev/null; then
    log_info "Adding $shell_path to /etc/shells..."
    echo "$shell_path" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change shell
  log_info "Changing default shell to $shell..."
  chsh -s "$shell_path"

  log_success "Default shell changed to $shell"
  log_warning "You may need to log out and back in for the change to take effect"
}
