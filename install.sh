#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_file="$repo_dir/.zshrc"
target_file="$HOME/.zshrc"

if [[ ! -f "$source_file" ]]; then
  printf 'Error: repository .zshrc was not found at %s\n' "$source_file" >&2
  exit 1
fi

if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
  printf '%s already points to %s\n' "$target_file" "$source_file"
  exit 0
fi

if [[ -e "$target_file" || -L "$target_file" ]]; then
  backup_file="$target_file.backup.$(date +%Y%m%d-%H%M%S)"
  mv -- "$target_file" "$backup_file"
  printf 'Backed up existing %s to %s\n' "$target_file" "$backup_file"
fi

ln -s -- "$source_file" "$target_file"
printf 'Linked %s to %s\n' "$target_file" "$source_file"
printf 'Run: source %s\n' "$target_file"
