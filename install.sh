#!/bin/sh
# iSH Toolkit — conservative Alpine package installer
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PKG_DIR="$ROOT_DIR/packages"
LOG_FILE="$ROOT_DIR/install.log"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root inside iSH (usually: sh install.sh)."
  exit 1
fi

if ! command -v apk >/dev/null 2>&1; then
  echo "This installer requires Alpine's apk package manager."
  exit 1
fi

usage() {
  echo "Usage: sh install.sh [all|basics|dev|python|network|security|text|media]"
  echo "No argument opens the category menu."
}

install_category() {
  category=$1
  list="$PKG_DIR/$category.txt"

  if [ ! -f "$list" ]; then
    echo "Unknown category: $category"
    return 1
  fi

  echo
  echo "== Installing category: $category =="
  while IFS= read -r pkg || [ -n "$pkg" ]; do
    case "$pkg" in ""|\#*) continue ;; esac

    if apk info -e "$pkg" >/dev/null 2>&1; then
      printf '[already installed] %s\n' "$pkg"
      continue
    fi

    printf '[installing] %s\n' "$pkg"
    if apk add "$pkg" >>"$LOG_FILE" 2>&1; then
      printf '[ok] %s\n' "$pkg"
    else
      printf '[skipped] %s (not available or install failed)\n' "$pkg"
    fi
  done < "$list"
}

install_all() {
  for category in basics dev python network security text media; do
    install_category "$category"
  done
}

echo "iSH Toolkit"
echo "-----------"
echo "This installs Alpine packages, not Kali Linux."
echo "Some packages may be unavailable on your iSH/Alpine version."
echo "Install log: $LOG_FILE"

mkdir -p "$ROOT_DIR"
: >> "$LOG_FILE"

if [ "${1-}" = "--help" ] || [ "${1-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "$#" -gt 0 ]; then
  if [ "$1" = "all" ]; then
    echo
    echo "This will attempt every package in the curated lists."
    printf "Continue? [y/N] "
    read answer
    case "$answer" in y|Y|yes|YES) install_all ;; *) echo "Cancelled."; exit 0 ;; esac
  else
    install_category "$1"
  fi
else
  echo
  echo "1) Basics"
  echo "2) Development"
  echo "3) Python"
  echo "4) Network diagnostics"
  echo "5) Defensive security"
  echo "6) Text and data"
  echo "7) Media and archives"
  echo "8) Everything"
  echo "q) Quit"
  printf "Choose: "
  read choice
  case "$choice" in
    1) install_category basics ;;
    2) install_category dev ;;
    3) install_category python ;;
    4) install_category network ;;
    5) install_category security ;;
    6) install_category text ;;
    7) install_category media ;;
    8)
      echo "This will attempt every package in the curated lists."
      printf "Continue? [y/N] "
      read answer
      case "$answer" in y|Y|yes|YES) install_all ;; *) echo "Cancelled."; exit 0 ;; esac
      ;;
    q|Q) exit 0 ;;
    *) echo "Invalid choice."; exit 1 ;;
  esac
fi

echo
echo "Finished. Review $LOG_FILE for package-manager output."
echo "A skipped package may be unavailable for your Alpine release or iSH architecture."