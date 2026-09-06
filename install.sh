#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_file="$repo_dir/.zshrc"
target_file="$HOME/.zshrc"

usage() {
  printf 'Usage: %s [install|check|remove|restore|git]\n' "$(basename "$0")"
}

check_installation() {
  if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    printf '%s points to %s\n' "$target_file" "$source_file"
    return 0
  fi

  printf '%s is not linked to %s\n' "$target_file" "$source_file"
  return 1
}

install_configuration() {
  if [[ ! -f "$source_file" ]]; then
    printf 'Error: repository .zshrc was not found at %s\n' "$source_file" >&2
    exit 1
  fi

  if check_installation; then
    return 0
  fi

  if [[ -e "$target_file" || -L "$target_file" ]]; then
    backup_file="$target_file.backup.$(date +%Y%m%d-%H%M%S)"
    backup_index=1
    while [[ -e "$backup_file" || -L "$backup_file" ]]; do
      backup_file="$target_file.backup.$(date +%Y%m%d-%H%M%S).$backup_index"
      backup_index=$((backup_index + 1))
    done
    mv "$target_file" "$backup_file"
    printf 'Backed up existing %s to %s\n' "$target_file" "$backup_file"
  fi

  ln -s "$source_file" "$target_file"
  printf 'Linked %s to %s\n' "$target_file" "$source_file"
  printf 'Run: source %s\n' "$target_file"
}

remove_configuration() {
  if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    rm "$target_file"
    printf 'Removed repository symlink %s\n' "$target_file"
    return 0
  fi

  printf 'No repository symlink found at %s; nothing removed\n' "$target_file"
}

restore_configuration() {
  if [[ ! -L "$target_file" || "$(readlink "$target_file")" != "$source_file" ]]; then
    printf 'No repository symlink found at %s; nothing restored\n' "$target_file"
    return 1
  fi

  backup_file="$(find "$HOME" -maxdepth 1 -type f -name '.zshrc.backup.*' -print | sort | tail -n 1)"
  if [[ -z "$backup_file" ]]; then
    printf 'No .zshrc backup found in %s\n' "$HOME" >&2
    return 1
  fi

  rm "$target_file"
  mv "$backup_file" "$target_file"
  printf 'Restored %s from %s\n' "$target_file" "$backup_file"
}

configure_git() {
  git config --global include.path "$repo_dir/.gitconfig"
  printf 'Configured Git to include %s\n' "$repo_dir/.gitconfig"
}

command="${1:-install}"
case "$command" in
  install)
    install_configuration
    ;;
  check)
    check_installation
    ;;
  remove)
    remove_configuration
    ;;
  restore)
    restore_configuration
    ;;
  git)
    configure_git
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
