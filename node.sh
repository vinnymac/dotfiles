#!/usr/bin/env bash
set -euo pipefail

mise use --global node@26.13.0 yarn@4
mise reshim
volta_dir="${VOLTA_HOME:-$HOME/.volta}/bin"
if [[ -x "$volta_dir/node" ]]; then
  if command -v volta >/dev/null 2>&1; then
    volta install node@26.13.0
  else
    echo 'Volta Node shim found, but volta is unavailable; its default was not changed.' >&2
  fi
fi
mise exec -- node --version
mise exec -- yarn --version
