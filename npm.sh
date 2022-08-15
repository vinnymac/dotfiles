#!/usr/bin/env bash

# Globally install with npm
packages=(
  eslint
  serverless
  maildev
  wifi-password-cli
  gh-pages
)

# check for npm, if it is missing, install nodejs

npm install -g "${packages[@]}"

# Install YVM
curl -s https://raw.githubusercontent.com/tophat/yvm/master/scripts/install.js | node
# Setup YVM
brew install tophat/bar/yvm
node "/opt/homebrew/opt/yvm/yvm.js" configure-shell --yvmDir "/opt/homebrew/opt/yvm"
source ~/.bash_profile;

# Install yarn
yarn --version
