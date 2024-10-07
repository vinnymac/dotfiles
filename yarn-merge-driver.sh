#!/usr/bin/env bash
# First, attempt to merge the lockfile using git's merge-file
git merge-file "$2" "$1" "$3"

# If the merge was successful (exit code 0), run yarn install to resolve potential issues
if [ $? -eq 0 ]; then
  echo "Git conflict resolved, running yarn install."
  yarn install

  if [ $? -ne 0 ]; then
    echo "Yarn install failed after conflict resolution."
    exit 1
  else
    echo "Yarn merge successful."
    exit 0
  fi
else
  echo "Git merge conflict couldn't be automatically resolved."
  exit 1
fi