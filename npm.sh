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
npm --version
node --version
yarn --version

npm install -g "${packages[@]}"

