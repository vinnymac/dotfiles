# vinnymac dotfiles

Modern, cross-platform dotfiles with interactive installation.

## Quick Start

```bash
git clone https://github.com/vinnymac/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --interactive
```

## Features

- Interactive installation with component selection
- Cross-platform support (macOS and Linux)
- Shell choice between bash and zsh
- Modular component installation
- Safe file backups before modifications
- Modern CLI tools (fzf, bat, eza, zoxide)
- Comprehensive error logging
- Dry-run mode to preview changes

## Installation Modes

### Interactive Mode (Recommended)

```bash
./install.sh --interactive
```

Prompts you to select:
- Shell preference (bash or zsh)
- Components to install (dev tools, applications, Node.js, etc.)
- Package categories (CTF tools, LLM apps, etc.)
- Platform-specific options (macOS settings, Xcode, Android tools)

### Other Modes

```bash
./install.sh --force          # Automated installation with defaults
./install.sh --dry-run         # Preview without making changes
./install.sh --config FILE     # Use custom configuration
./install.sh --help            # Show all options
```

## Customization

Create a custom configuration:

```bash
cp config/default.conf config/user.conf
# Edit config/user.conf to customize preferences
./install.sh
```

The `config/user.conf` file is gitignored for personal preferences.

## What Gets Installed

### Core Components

- Package Manager: Homebrew (macOS), apt/dnf/pacman (Linux)
- Development Tools: git, vim, asdf, python, ansible
- Modern CLI Tools: fzf, bat, eza, fd, zoxide
- Git Tools: git-lfs, gh, git-delta

### Optional Components

- GUI Applications: Firefox, VSCodium, Zed, Bitwarden, Slack
- Node.js Tools: Volta, Node 22, Yarn 4
- AWS CLI
- CTF/Security Tools: nmap, john, hydra, aircrack-ng
- LLM Applications: Claude Code, Codex, Gemini CLI

### macOS-Specific

- Xcode and Command Line Tools
- Android Studio and SDK
- macOS system settings (.macos script)
- Quick Look plugins

## Configuration Files

**Main Configuration:**
- `config/default.conf` - Default settings
- `config/user.conf` - Personal overrides (gitignored)
- `config/packages.conf` - Package definitions

**Shell Configuration:**
- `.bash_profile` - Bash configuration
- `.zshrc` - Zsh configuration (created if selected)
- `.aliases` - Custom aliases and functions
- `.exports` - Environment variables

## Platform Support

**macOS:**
- Intel and Apple Silicon
- Homebrew package manager
- System settings configuration

**Linux:**
- Ubuntu/Debian (apt)
- Fedora/RHEL (dnf/yum)
- Arch Linux (pacman)

Note: Some GUI applications may not be available on all Linux distributions.

## Troubleshooting

**Installation Logs:**

Check `/tmp/dotfiles-install-*.log` if something goes wrong.

**Common Issues:**

Shell not changing:
- Log out and back in after changing shells
- Verify shell is in `/etc/shells`

Permissions errors:
- Don't run as root
- Script will request sudo when needed

Package installation failures:
- Individual failures won't stop installation
- Check error summary at end
- Review log file for details

## What's New in v2.0

- Interactive mode for component selection
- Improved Linux support with multiple distro detection
- Shell choice (bash or zsh)
- Dry-run mode
- Comprehensive error logging
- Configuration file system
- Modular architecture with reusable libraries
- Modern bash best practices (set -euo pipefail)
- Fixed critical bugs (brew detection, shell forcing)

## License

MIT License - see [LICENSE.md](LICENSE.md)
