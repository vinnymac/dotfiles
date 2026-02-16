# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don't want to commit.
for file in ~/.{path,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Git-aware prompt
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Enable command substitution in prompt
setopt PROMPT_SUBST

# Set up colored prompt: username@hostname: path (branch) $
PROMPT='%F{green}%n@%m%f%F{blue}: %~%f%F{yellow}$(parse_git_branch)%f%F{blue} %# %f'

# Set up Homebrew/Linuxbrew shell environment
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
  if [[ "$(uname -p)" == "arm" ]]; then
    brew_cmd="/opt/homebrew/bin/brew"
  else
    brew_cmd="/usr/local/bin/brew"
  fi
  if [[ -x "$brew_cmd" ]]; then
    eval "$(${brew_cmd} shellenv)"
  fi
elif [[ "$(uname)" == "Linux" ]]; then
  # Linux - check for Linuxbrew
  if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# Set up fzf key bindings and fuzzy completion (only if fzf is installed)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)

  # -- Use fd instead of fzf --
  if command -v fd &> /dev/null; then
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
  fi

  # File/directory preview with eza and bat (if available)
  if command -v eza &> /dev/null && command -v bat &> /dev/null; then
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
  fi
fi

# ---- Zoxide (better cd) ----
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Additional PATH configurations (only if they exist)
[[ -d "/usr/local/opt/openssl/bin" ]] && export PATH="/usr/local/opt/openssl/bin:$PATH"
[[ -d "/usr/local/sbin" ]] && export PATH="/usr/local/sbin:$PATH"
