#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
	green=$'\033[32m'
	red=$'\033[31m'
	reset=$'\033[0m'
else
	green=''
	red=''
	reset=''
fi

run_check() {
	label="$1"
	shift

	printf '%-32s' "$label"
	if "$@"; then
		printf '%sOK%s\n' "$green" "$reset"
	else
		check_status=$?
		printf '%sFAIL%s\n' "$red" "$reset" >&2
		return "$check_status"
	fi
}

run_check 'Bash syntax' bash -n install.sh
run_check 'NVM Bash syntax' bash -n install-nvm.sh
run_check 'Environment Bash syntax' bash -n check-environment.sh
run_check 'Zsh syntax' zsh -n .zshrc
run_check 'Git whitespace' git diff --check

tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT

install_for_validation() {
	HOME="$tmp_home" ./install.sh >/dev/null
}

check_for_validation() {
	HOME="$tmp_home" ./install.sh check >/dev/null
}

check_nvm_for_validation() {
	HOME="$tmp_home" NVM_DIR="$tmp_home/.nvm" NVM_SKIP_NETWORK=1 ./install-nvm.sh check >"$tmp_home/nvm-check.out"
	grep -q 'Upstream status.*local checks only' "$tmp_home/nvm-check.out"
	grep -q 'Review upstream status' "$tmp_home/nvm-check.out"
}

check_environment_for_validation() {
	environment_home="$tmp_home/environment-home"
	mkdir -p "$environment_home/.ssh"
	chmod 700 "$environment_home/.ssh"
	printf 'prefix=%s\n' "$environment_home/.npm-global" >"$environment_home/.npmrc"
	printf 'ssh-ed25519 AAAA validation\n' >"$environment_home/.ssh/id_ed25519.pub"
	HOME="$environment_home" NVM_DIR="$environment_home/.nvm" ./check-environment.sh >"$environment_home/environment-check.out"
	grep -q 'npmrc NVM compatibility.*review prefix' "$environment_home/environment-check.out"
	grep -q 'SSH public key.*id_ed25519.pub' "$environment_home/environment-check.out"
	grep -q 'audit is read-only' "$environment_home/environment-check.out"
}

run_check 'Install behavior' install_for_validation
run_check 'Symlink created' test -L "$tmp_home/.zshrc"
run_check 'Symlink target' test "$(readlink "$tmp_home/.zshrc")" = "$script_dir/.zshrc"
run_check 'Check behavior' check_for_validation
run_check 'NVM check behavior' check_nvm_for_validation
run_check 'NVM check is read-only' test ! -e "$tmp_home/.nvm"
run_check 'Environment check behavior' check_environment_for_validation

printf '\n%sValidation passed%s\n' "$green" "$reset"