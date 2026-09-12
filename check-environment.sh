#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ssh_dir="${HOME}/.ssh"
npmrc_file="${NPM_CONFIG_USERCONFIG:-${HOME}/.npmrc}"
nvm_dir="${NVM_DIR:-${HOME}/.nvm}"

usage() {
	printf 'Usage: %s [check]\n' "$(basename "$0")"
	printf '\n'
	printf 'check   Report local development environment readiness (default).\n'
}

report() {
	printf '%-24s %s\n' "$1" "$2"
}

command_version() {
	command_name="$1"
	if command -v "$command_name" >/dev/null 2>&1; then
		case "$command_name" in
			brew)
				version="$(brew --version 2>/dev/null | head -n 1 || true)"
				;;
			curl)
				version="$(curl --version 2>/dev/null | head -n 1 || true)"
				;;
			git)
				version="$(git --version 2>/dev/null || true)"
				;;
			node)
				version="$(node --version 2>/dev/null || true)"
				;;
			npm)
				version="$(npm --version 2>/dev/null || true)"
				;;
			*)
				version='available'
				;;
		esac
		report "$command_name" "${version:-available}"
	else
		report "$command_name" 'not found'
	fi
}

check_node_tooling() {
	if [[ -s "$nvm_dir/nvm.sh" ]]; then
		report 'NVM' 'installed'
	else
		report 'NVM' 'not found'
	fi

	command_version node
	command_version npm

	if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
		if node_path="$(command -v node)" && npm_path="$(command -v npm)"; then
			report 'Node/npm paths' "$node_path ; $npm_path"
		fi
	fi
}

check_npm_configuration() {
	if [[ ! -e "$npmrc_file" ]]; then
		report 'User npmrc' 'not found'
		return 0
	fi

	report 'User npmrc' "$npmrc_file"
	if grep -Eq '^[[:space:]]*(prefix|globalconfig)[[:space:]]*=' "$npmrc_file"; then
		report 'npmrc NVM compatibility' 'review prefix/globalconfig settings'
	else
		report 'npmrc NVM compatibility' 'no conflicting prefix/globalconfig found'
	fi

	if grep -Eiq '(^|[[:space:]])(_auth|_authToken|password|username)[[:space:]]*=' "$npmrc_file"; then
		report 'npmrc credentials' 'present; keep this file out of Git'
	else
		report 'npmrc credentials' 'no obvious credentials found'
	fi
}

check_ssh() {
	if [[ ! -d "$ssh_dir" ]]; then
		report 'SSH directory' 'not found'
		return 0
	fi

	report 'SSH directory' "$ssh_dir"
	ssh_permissions="$(stat -f '%Lp' "$ssh_dir" 2>/dev/null || stat -c '%a' "$ssh_dir" 2>/dev/null || printf 'unknown')"
	if [[ "$ssh_permissions" == '700' ]]; then
		report 'SSH permissions' '700'
	else
		report 'SSH permissions' "$ssh_permissions (recommended: 700)"
	fi

	public_key_count=0
	while IFS= read -r public_key; do
		public_key_count=$((public_key_count + 1))
		report 'SSH public key' "${public_key##*/}"
	done < <(find "$ssh_dir" -maxdepth 1 -type f \( -name '*.pub' -o -name 'id_*' \) -name '*.pub' -print 2>/dev/null | sort)
	if (( public_key_count == 0 )); then
		report 'SSH public key' 'not found'
	fi

	if command -v ssh-add >/dev/null 2>&1; then
		if ssh-add -l >/dev/null 2>&1; then
			report 'SSH agent' 'has loaded keys'
		else
			report 'SSH agent' 'available, no loaded keys'
		fi
	else
		report 'SSH agent' 'ssh-add not found'
	fi
}

check_environment() {
	printf 'Development environment assessment\n'
	printf '%s\n' '================================='
	report 'Platform' "$(uname -s) $(uname -m)"
	report 'Shell' "${SHELL:-unknown}"
	report 'Repository' "$script_dir"

	command_version git
	command_version curl
	command_version brew
	check_node_tooling
	check_npm_configuration
	check_ssh

	printf '\nNext steps\n'
	if [[ ! -s "$nvm_dir/nvm.sh" ]]; then
		printf '%s\n' 'NVM is not installed; run ./install-nvm.sh for an assessment.'
	fi
	if [[ ! -e "$npmrc_file" ]]; then
		printf '%s\n' 'No user npmrc is present; create one only with non-secret preferences.'
	fi
	if [[ ! -d "$ssh_dir" ]]; then
		printf '%s\n' 'SSH is not configured; create keys separately and never store private keys here.'
	fi
	printf '%s\n' 'This audit is read-only and does not install tools, create keys, or contact hosts.'
}

command_name="${1:-check}"
case "$command_name" in
	check)
		check_environment
		;;
	-h|--help)
		usage
		;;
	*)
		usage >&2
		exit 1
		;;
esac
