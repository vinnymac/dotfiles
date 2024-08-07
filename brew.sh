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
brew install gnu-sed --with-default-names
# Install Bash 4.
brew install bash \
  bash-completion2 \
  fzf \
  bat

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
  chsh -s "${BREW_PREFIX}/bin/bash"
fi

# Install `wget` with IRI support.
brew install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
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

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

# Terminal Recording
brew install asciinema
brew install agg

# Install other useful binaries.
brew install ack
#brew install exiv2
brew install git
brew install git-lfs
brew install gh
# Create diff highlight
make -C $(brew --prefix git)/share/git-core/contrib/diff-highlight
brew install imagemagick --with-webp
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli
brew install htop
brew install ansible
brew install git-delta

brew tap homebrew/cask-fonts
brew install --cask font-fira-code
brew install --cask font-0xproto-nerd-font

# Install packages
apps=(
  atom
  docker
  firefox
  firefox-nightly
  google-chrome
  google-chrome-canary
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
  visual-studio-code
  vlc
  cron
)

for app in "${apps[@]}"; do brew install --cask --appdir="/Applications" "$app"; done

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew install --cask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv webpquicklook suspicious-package &&
  xattr -cr ~/Library/QuickLook/*.qlgenerator &&
  qlmanage -r &&
  qlmanage -r cache

# Remove outdated versions from the cellar.
brew cleanup
