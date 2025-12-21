#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
# Install Bash 4.
brew install bash \
  bash-completion2 \
  fzf \
  bat \
  eza \
  fd \
  zoxide

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
  chsh -s "${BREW_PREFIX}/bin/bash"
fi

# Install `wget` with IRI support.
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
# Uncomment this for linux
# brew install openssh
brew install screen \
  php \
  gmp

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff \
  sfnt2woff-zopfli \
  woff2

# Deskflow - https://github.com/deskflow/homebrew-tap
brew tap deskflow/homebrew-tap
brew install deskflow

# Install some CTF tools; see https://github.com/ctfs/write-ups.
ctfs=(
  aircrack-ng
  binutils
  binwalk
  cifer
  dex2jar
  dns2tcp
  fcrackzip
  foremost
  hydra
  john
  knock
  netpbm
  nmap
  pngcheck
  socat
  sqlmap
  tcpflow
  tcpreplay
  ucspi-tcp # `tcpserver` etc.
  xpdf
  xz
)
for ctf in "${ctfs[@]}"; do brew install "$ctf"; done

# Install other useful binaries.
bins=(
  python
  # Terminal Recording
  asciinema
  agg
  # Git
  git
  git-lfs
  gh
  git-delta
  imagemagick
  ack
  lua
  lynx
  p7zip
  pigz
  pv
  rename
  rlwrap
  ssh-copy-id
  tree
  vbindiff
  htop
  ansible
  orbstack
  asdf
  gemini-cli
)
for bin in "${bins[@]}"; do brew install "$bin"; done

brew install --cask
brew install --cask font-0xproto-nerd-font

# Install packages
apps=(
  firefox
  firefox@nightly
  # Fuck Google
  # google-chrome
  # google-chrome@canary
  ungoogled-chromium
  iterm2
  keepingyouawake
  keka
  keycastr
  macdown
  slack
  sourcetree
  transmission
  vagrant
  virtualbox
  # Fuck Microsoft
  # visual-studio-code
  vscodium
  zed
  zen
  vlc
  cron
  raycast
  datagrip
  linear-linear
  bitwarden
  shottr
  background-music
  rectangle
  PlayCover/playcover/playcover-community
  # LLMs
  claude-code
  codex
)

for app in "${apps[@]}"; do brew install --cask --appdir="/Applications" "$app"; done

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
# Sequoia and higher do not support legacy quick look plugins
# https://developer.apple.com/documentation/macos-release-notes/macos-15-release-notes
brew install suspicious-package apparency qlvideo
# Glance - https://github.com/chamburr/glance - Quick Look
# Replaces - qlcolorcode qlstephen qlmarkdown quicklook-json quicklookase
brew install --no-quarantine glance-chamburr

# Gemini install node as a dependency, but we already install node, so remove it
brew uninstall --ignore-dependencies node

# Remove outdated versions from the cellar.
brew cleanup
