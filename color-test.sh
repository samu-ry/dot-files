#!/usr/bin/env bash
set -euo pipefail

printf 'ANSI colors:\n'
for color in 31 32 33 34 35 36 37; do
  printf '\033[%smColor %s\033[0m  ' "$color" "$color"
done
printf '\n\n'

printf 'Prompt colors:\n'
printf '\033[36mCyan host\033[0m  '
printf '\033[32mGreen directory\033[0m  '
printf '\033[35mMagenta branch\033[0m  '
printf '\033[33mYellow clock\033[0m\n'

printf '\nDirectory colors:\n'
ls -G