#!/bin/sh
# iSH Toolkit system doctor — read-only diagnostics
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PKG_DIR="$ROOT_DIR/packages"

section() {
  printf "\n== %s ==\n" "$1"
}

section "Platform"
printf "Alpine: "
if [ -r /etc/alpine-release ]; then
  cat /etc/alpine-release
else
  echo "not detected"
fi
printf "Architecture: "
uname -m 2>/dev/null || echo "unknown"
printf "Kernel: "
uname -sr 2>/dev/null || echo "unknown"
printf "Shell: %s\n" "${SHELL:-unknown}"

section "Storage"
if command -v df >/dev/null 2>&1; then
  df -h /
else
  echo "df is not installed"
fi

section "Core commands"
for cmd in apk git python3 pip3 curl wget openssl; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "[found]     %s\n" "$cmd"
  else
    printf "[not found] %s\n" "$cmd"
  fi
done

section "Toolkit package status"
total=0
installed=0
for list in "$PKG_DIR"/*.txt; do
  [ -f "$list" ] || continue
  while IFS= read -r pkg || [ -n "$pkg" ]; do
    case "$pkg" in ""|\#*) continue ;; esac
    total=$((total + 1))
    if apk info -e "$pkg" >/dev/null 2>&1; then
      installed=$((installed + 1))
    fi
  done < "$list"
done
printf "Installed: %s / %s listed packages\n" "$installed" "$total"

section "Network configuration"
if command -v ip >/dev/null 2>&1; then
  ip addr show 2>/dev/null | sed -n '1,24p'
else
  echo "iproute2 is not installed; skipping interface details"
fi
if [ -r /etc/resolv.conf ]; then
  echo "DNS configuration:"
  sed -n '1,8p' /etc/resolv.conf
fi

section "Finished"
echo "This report is informational. iSH emulates a Linux userland and does not expose every normal Linux feature."
