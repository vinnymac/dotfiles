#!/usr/bin/env bash
set -euo pipefail

mise use --global node@22.19.0 yarn@4
mise reshim
mise exec -- node --version
mise exec -- yarn --version
