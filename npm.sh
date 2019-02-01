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
