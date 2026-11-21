#!/bin/sh
set -u
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
echo "iSH / Alpine environment"
echo "------------------------"
[ -r /etc/alpine-release ] && printf "Alpine: " && cat /etc/alpine-release
printf "Kernel/emulation info: "
uname -a
echo
echo "Installed packages from this toolkit's lists:"
for list in "$ROOT_DIR"/packages/*.txt; do
  [ -f "$list" ] || continue
  while IFS= read -r pkg || [ -n "$pkg" ]; do
    case "$pkg" in ""|\#*) continue ;; esac
    if apk info -e "$pkg" >/dev/null 2>&1; then
      echo "  [installed] $pkg"
    fi
  done < "$list"
done