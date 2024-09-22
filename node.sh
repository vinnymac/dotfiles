#!/usr/bin/env bash

# Globally installable packages
# packages = (
#   eslint
#   serverless
#   maildev
#   wifi-password-cli
#   gh-pages
# )
# npm install -g "${packages[@]}"

# Install Latest Node 20
volta install node@20
# Install Latest Yarn 4
volta install yarn@4

# check for npm, if it is missing, install nodejs
npm --version
node --version
yarn --version


