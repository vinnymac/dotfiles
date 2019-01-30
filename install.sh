#!/usr/bin/env bash

# install.sh — Shell software installation script
# Created by vinnymac (https://github.com/vinnymac/dotfiles)

cd "$(dirname "${BASH_SOURCE}")";

echo "Shell installation script for vinnymac's dotfiles";
echo "-------------------------------------------------";
echo "";

platform='undefined';
unamestr=`uname`;
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux';
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='darwin';
fi

installBrew() {
  if hash elixir 2>/dev/null; then
    echo "[INFO] Brew already installed."
  else
    echo "[INFO] Installing Homebrew package manager...";
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
  fi
}

updateBrew() {
  if hash elixir 2>/dev/null; then
    echo "[INFO] Updating Homebrew package manager...";
    brew update;
  fi
}

installSoftware() {
  /bin/bash ./brew.sh;
  /bin/bash ./aws.sh;
  /bin/bash ./npm.sh;
}

installAsdf() {
  # Clone repository
  echo "[INFO] Cloning asdf repository...";
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf;

  echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc;
  echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc;
  source ~/.bashrc;

  # Install useful plugins (at least for me :D)
  echo "[INFO] Installing asdf plugins...";
  source $HOME/.asdf/asdf.sh;

  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git;
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git;
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring;
  asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git;
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git;
  asdf plugin-add terraform https://github.com/Banno/asdf-hashicorp.git;
  asdf plugin-add packer https://github.com/Banno/asdf-hashicorp.git;
}

syncConfig() {
  echo "[INFO] Syncing configuration...";

  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".macos" \
    --exclude "README.md" \
    --exclude "npm.sh" \
    --exclude "brew.sh" \
    --exclude "install.sh" \
    --exclude "aws.sh" \
    -avh --no-perms . ~;
}

macOsConfig() {
  /bin/bash ~/.macos;
}

doIt() {
  installBrew;
  updateBrew;

  installSoftware;
  installAsdf;
  syncConfig;
  macOsConfig;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite files in your home directory. Do you want to continue? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;

echo "";
echo "[INFO] If there isn't any error message, the process is completed.";
