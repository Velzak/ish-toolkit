#!/bin/sh
# iSH Toolkit — interactive Alpine package installer
set -u

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PKG_DIR="$ROOT_DIR/packages"
LOG_FILE="$ROOT_DIR/install.log"

# Use color only in an interactive terminal; NO_COLOR disables it.
if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_BLUE='\033[1;34m'
  C_CYAN='\033[1;36m'
  C_GREEN='\033[1;32m'
  C_YELLOW='\033[1;33m'
  C_RED='\033[1;31m'
else
  C_RESET=''
  C_BOLD=''
  C_BLUE=''
  C_CYAN=''
  C_GREEN=''
  C_YELLOW=''
  C_RED=''
fi

paint() {
  color=$1
  shift
  printf '%b%s%b\n' "$color" "$*" "$C_RESET"
}

if [ "$(id -u)" -ne 0 ]; then
  paint "$C_RED" "Run this script as root inside iSH (usually: sh install.sh)."
  exit 1
fi

if ! command -v apk >/dev/null 2>&1; then
  paint "$C_RED" "This installer requires Alpine's apk package manager."
  exit 1
fi

usage() {
  echo "Usage: sh install.sh [all|basics|dev|python|network|security|text|media]"
  echo "Run without arguments for the interactive menu."
}

confirm_all() {
  echo
  paint "$C_YELLOW" "This will attempt every package in the curated lists."
  printf "Continue? [y/N] "
  IFS= read -r answer || answer=''
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) paint "$C_YELLOW" "Cancelled."; return 1 ;;
  esac
}

install_category() {
  selected_category=$1
  list="$PKG_DIR/$selected_category.txt"

  if [ ! -f "$list" ]; then
    paint "$C_RED" "Unknown category: $selected_category"
    return 1
  fi

  total=$(awk '!/^[[:space:]]*($|#)/ { count++ } END { print count+0 }' "$list")
  if [ "$total" -eq 0 ]; then
    paint "$C_YELLOW" "No packages listed in $selected_category."
    return 0
  fi

  echo
  paint "$C_BLUE" "┌─ Installing: $selected_category"
  printf '  Packages queued: %s\n' "$total"
  paint "$C_BLUE" "└────────────────────────────────"

  index=0
  ok=0
  skipped=0
  already=0

  while IFS= read -r package_name || [ -n "$package_name" ]; do
    case "$package_name" in ""|\#*) continue ;; esac
    index=$((index + 1))
    printf '%s[%s/%s]%s ' "$C_CYAN" "$index" "$total" "$C_RESET"

    if apk info -e "$package_name" >/dev/null 2>&1; then
      printf '%b[installed]%b %s\n' "$C_GREEN" "$C_RESET" "$package_name"
      already=$((already + 1))
      continue
    fi

    printf 'Installing %s... ' "$package_name"
    if apk add "$package_name" >>"$LOG_FILE" 2>&1; then
      printf '%bOK%b\n' "$C_GREEN" "$C_RESET"
      ok=$((ok + 1))
    else
      printf '%bSKIP%b\n' "$C_YELLOW" "$C_RESET"
      skipped=$((skipped + 1))
      printf '[%s] package install failed or unavailable\n' "$package_name" >>"$LOG_FILE"
    fi
  done < "$list"

  echo
  printf 'Summary: %b%s installed%b, %b%s already present%b, %b%s skipped%b\n' \
    "$C_GREEN" "$ok" "$C_RESET" "$C_CYAN" "$already" "$C_RESET" \
    "$C_YELLOW" "$skipped" "$C_RESET"
}

install_all() {
  for selected_category in basics dev python network security text media; do
    install_category "$selected_category"
  done
}

show_menu() {
  while :; do
    echo
    paint "$C_CYAN" "╔══════════════════════════════════╗"
    paint "$C_CYAN" "║          iSH TOOLKIT             ║"
    paint "$C_CYAN" "╚══════════════════════════════════╝"
    echo "  Alpine package manager for iSH"
    echo
    printf '  %b1%b  Basics and shell tools\n' "$C_BOLD" "$C_RESET"
    printf '  %b2%b  Development tools\n' "$C_BOLD" "$C_RESET"
    printf '  %b3%b  Python environment\n' "$C_BOLD" "$C_RESET"
    printf '  %b4%b  Network diagnostics\n' "$C_BOLD" "$C_RESET"
    printf '  %b5%b  Defensive security\n' "$C_BOLD" "$C_RESET"
    printf '  %b6%b  Text and data tools\n' "$C_BOLD" "$C_RESET"
    printf '  %b7%b  Media and archives\n' "$C_BOLD" "$C_RESET"
    printf '  %ba%b  Attempt all categories\n' "$C_BOLD" "$C_RESET"
    printf '  %bd%b  Run system doctor\n' "$C_BOLD" "$C_RESET"
    printf '  %bq%b  Quit\n' "$C_BOLD" "$C_RESET"
    echo
    printf '  Select an option: '
    IFS= read -r choice || choice='q'

    case "$choice" in
      1) install_category basics ;;
      2) install_category dev ;;
      3) install_category python ;;
      4) install_category network ;;
      5) install_category security ;;
      6) install_category text ;;
      7) install_category media ;;
      a|A) if confirm_all; then install_all; fi ;;
      d|D)
        if [ -f "$ROOT_DIR/doctor.sh" ]; then
          sh "$ROOT_DIR/doctor.sh"
        else
          paint "$C_YELLOW" "doctor.sh is missing. Update your repository with git pull."
        fi
        ;;
      q|Q) paint "$C_GREEN" "See you next time."; break ;;
      *) paint "$C_RED" "Invalid option. Choose one of the listed options." ;;
    esac
  done
}

: >> "$LOG_FILE"

if [ "${1-}" = "--help" ] || [ "${1-}" = "-h" ]; then
  usage
  exit 0
fi

paint "$C_BOLD" "iSH Toolkit"
echo "A lightweight package manager menu for Alpine on iOS."
paint "$C_YELLOW" "Note: this is not Kali Linux; some packages/features are unavailable in iSH."
printf 'Install log: %s\n' "$LOG_FILE"

if [ "$#" -gt 0 ]; then
  if [ "$1" = "all" ]; then
    if confirm_all; then install_all; fi
  else
    install_category "$1"
  fi
else
  show_menu
fi

echo
paint "$C_GREEN" "Done. Check install.log for full package-manager output."
echo "Some skipped packages may not be available for your iSH Alpine release."
