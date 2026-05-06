#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'
trap 'printf "error: %s\n" "doctor failed on: $BASH_COMMAND" >&2; exit 1' ERR

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly BREWFILE="${BREWFILE:-$REPO_ROOT/Brewfile}"

status=0

function has() { command -v "$1" >/dev/null 2>&1; }

function section() {
  printf '\n==> %s\n' "$*"
}

function soft_fail() {
  printf 'warning: %s\n' "$*" >&2
  status=1
}

function check_brew_bundle() {
  section "Brewfile"
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$BREWFILE" || soft_fail "Brewfile dependencies are not fully satisfied"
}

function check_brew_doctor() {
  section "Homebrew doctor"
  brew doctor || true
}

function check_code() {
  section "VS Code CLI"
  if has code; then
    code --version || soft_fail "code CLI failed"
  else
    soft_fail "code CLI is not available"
  fi
}

function check_docker() {
  section "Docker"
  if has docker; then
    docker --version || soft_fail "docker CLI failed"
  else
    soft_fail "docker CLI is not available"
  fi
}

function main() {
  has brew || soft_fail "brew is not available"
  if has brew; then
    check_brew_bundle
    check_brew_doctor
  fi

  check_code
  check_docker

  if (( status == 0 )); then
    printf '\ndoctor passed\n'
  else
    printf '\ndoctor found issues\n' >&2
  fi

  exit "$status"
}

main "$@"
