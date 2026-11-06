#!/usr/bin/env bash
set -euo pipefail

mise use --global node@26.13.0 yarn@4
mise reshim
volta_dir="${VOLTA_HOME:-$HOME/.volta}/bin"
if [[ -x "$volta_dir/node" ]] && command -v volta >/dev/null 2>&1; then
  volta install node@26.13.0
fi
mise exec -- node --version
mise exec -- yarn --version
