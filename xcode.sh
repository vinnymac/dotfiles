#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

agree_with_xcode_licence() {
  # Automatically agree to the terms of the `Xcode` license.
  # https://github.com/alrra/dotfiles/issues/10

  sudo xcodebuild -license accept &> /dev/null
  echo $? "Agree to the terms of the Xcode licence"
}

are_xcode_command_line_tools_installed() {
  xcode-select --print-path &> /dev/null
}

install_xcode() {
  # If necessary, prompt user to install `Xcode`.

  if ! is_xcode_installed; then
    open "macappstores://itunes.apple.com/en/app/xcode/id497799835"
  fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Wait until `Xcode` is installed.

  until is_xcode_installed; do
    sleep 5;
  done

  echo "Found Xcode.app"
}

install_xcode_command_line_tools() {
  # If necessary, prompt user to install
  # the `Xcode Command Line Tools`.

  xcode-select --install &> /dev/null

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Wait until the `Xcode Command Line Tools` are installed.

  until are_xcode_command_line_tools_installed; do
    sleep 5;
  done

  echo "Found Xcode Command Line Tools"
}

is_xcode_installed() {
  [ -d "/Applications/Xcode.app" ]
}

set_xcode_developer_directory() {
  # Point the `xcode-select` developer directory to
  # the appropriate directory from within `Xcode.app`.
  #
  # https://github.com/alrra/dotfiles/issues/13

  sudo xcode-select -switch "/Applications/Xcode.app/Contents/Developer" &> /dev/null
  echo $? "Make 'xcode-select' developer directory point to the appropriate directory from within Xcode.app"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
  echo 'Install Xcode'

  install_xcode_command_line_tools
  install_xcode
  set_xcode_developer_directory
  agree_with_xcode_licence
}

main
