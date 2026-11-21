#!/bin/sh
set -eu

if ! command -v apk >/dev/null 2>&1; then
  echo "apk was not found. Run this inside iSH."
  exit 1
fi

echo "Refreshing Alpine package indexes..."
apk update
echo
echo "Upgrading installed packages..."
echo "Note: on older iSH Alpine images, repositories may be outdated or unavailable."
apk upgrade