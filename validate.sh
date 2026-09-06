#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

bash -n install.sh
zsh -n .zshrc
git diff --check

tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT

HOME="$tmp_home" ./install.sh
test -L "$tmp_home/.zshrc"
test "$(readlink "$tmp_home/.zshrc")" = "$script_dir/.zshrc"
HOME="$tmp_home" ./install.sh check

printf 'Validation passed\n'