#!/usr/bin/env bash

# Globally install with npm
packages=(
  eslint
  serverless
  maildev
  wifi-password-cli
  gh-pages
)

npm install -g "${packages[@]}"
