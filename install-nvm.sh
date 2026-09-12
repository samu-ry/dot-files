#!/usr/bin/env bash
set -euo pipefail

NVM_VERSION="${NVM_VERSION:-v0.40.7}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_REPOSITORY="nvm-sh/nvm"
NVM_API_BASE="${NVM_API_BASE:-https://api.github.com/repos/$NVM_REPOSITORY}"
NVM_RAW_BASE="${NVM_RAW_BASE:-https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION}"

usage() {
	printf 'Usage: %s [check|install]\n' "$(basename "$0")"
	printf '\n'
	printf 'check   Assess whether NVM is current and appropriate (default).\n'
	printf 'install Run the reviewed, pinned NVM installer after the assessment.\n'
}

report() {
	printf '%-24s %s\n' "$1" "$2"
}

require_command() {
	if command -v "$1" >/dev/null 2>&1; then
		report "$1" 'available'
		return 0
	fi

	report "$1" 'missing'
	return 1
}

fetch_metadata() {
	metadata_dir="$1"
	if [[ "${NVM_SKIP_NETWORK:-0}" == '1' ]]; then
		return 1
	fi

	if ! curl --fail --silent --show-error --location --max-time 15 \
		-H 'Accept: application/vnd.github+json' \
		"$NVM_API_BASE/releases/latest" >"$metadata_dir/release.json"; then
		return 1
	fi

	if ! curl --fail --silent --show-error --location --max-time 15 \
		-H 'Accept: application/vnd.github+json' \
		"$NVM_API_BASE/commits?per_page=1" >"$metadata_dir/commits.json"; then
		return 1
	fi

	if ! curl --fail --silent --show-error --location --max-time 15 \
		"$NVM_RAW_BASE/README.md" >"$metadata_dir/readme.md"; then
		return 1
	fi
}

json_value() {
	key="$1"
	file="$2"
	sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\)\".*/\\1/p" "$file" | head -n 1
}

check_local_state() {
	if [[ -s "$NVM_DIR/nvm.sh" ]]; then
		nvm_version='installed'
		if [[ -d "$NVM_DIR/.git" ]]; then
			nvm_version="$(git -C "$NVM_DIR" describe --tags --exact-match 2>/dev/null || printf 'unreleased checkout')"
		fi
		report 'NVM installation' "$nvm_version"
	else
		report 'NVM installation' 'not found'
	fi

	if command -v node >/dev/null 2>&1; then
		report 'Node.js' "$(node --version 2>/dev/null || printf 'available')"
	else
		report 'Node.js' 'not found'
	fi

	if [[ -f .nvmrc ]]; then
		report '.nvmrc' "present ($(tr -d '[:space:]' < .nvmrc))"
	else
		report '.nvmrc' 'not found in current directory'
	fi

	if command -v mise >/dev/null 2>&1; then
		report 'Alternative manager' "mise ($(mise --version 2>/dev/null || printf 'installed'))"
	elif command -v asdf >/dev/null 2>&1; then
		report 'Alternative manager' "asdf ($(asdf version 2>/dev/null || printf 'installed'))"
	else
		report 'Alternative manager' 'mise/asdf not found'
	fi

	if command -v brew >/dev/null 2>&1 && brew list --formula nvm >/dev/null 2>&1; then
		report 'Homebrew NVM' 'installed (not recommended by upstream)'
	else
		report 'Homebrew NVM' 'not found'
	fi

	if grep -q 'NVM_DIR' "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.zshrc" 2>/dev/null; then
		report 'Repository integration' 'loads NVM from ~/.nvm'
	else
		report 'Repository integration' 'NVM loading not found'
	fi
}

check_upstream_state() {
	metadata_dir="$1"
	if ! fetch_metadata "$metadata_dir"; then
		report 'Upstream status' 'unavailable; local checks only'
		return 1
	fi

	latest_release="$(json_value tag_name "$metadata_dir/release.json")"
	latest_release_date="$(json_value published_at "$metadata_dir/release.json")"
	latest_commit_date="$(json_value date "$metadata_dir/commits.json")"
	support_version="$(sed -n 's/.*Only the latest version (\(v[0-9.]*\) at this time).*/\1/p' "$metadata_dir/readme.md" | head -n 1)"
	security_signal='none found in latest release notes'
	if grep -Eiq 'security|CVE' "$metadata_dir/release.json"; then
		security_signal='security-related release note present'
	fi

	report 'Latest NVM release' "${latest_release:-unavailable} (${latest_release_date:-date unavailable})"
	report 'Latest commit' "${latest_commit_date:-date unavailable}"
	report 'Official support' "${support_version:-not stated in README}"
	report 'Release notes' "$security_signal"

	if [[ "$latest_release" != "$NVM_VERSION" ]]; then
		report 'Pinned version' "$NVM_VERSION (review: upstream is ${latest_release:-unknown})"
		return 1
	fi

	report 'Pinned version' "$NVM_VERSION (matches latest release)"
	return 0
}

check_configuration() {
	printf 'NVM relevance assessment\n'
	printf '%s\n' '========================'
	report 'Platform' "$(uname -s) $(uname -m)"
	report 'Shell' "${SHELL:-unknown}"
	assessment_upstream_current=0

	local missing=0
	require_command bash || missing=1
	require_command curl || missing=1
	require_command git || missing=1
	check_local_state

	metadata_dir="$(mktemp -d)"
	trap 'rm -rf "$metadata_dir"' RETURN
	upstream_current=1
	check_upstream_state "$metadata_dir" || upstream_current=0
	assessment_upstream_current="$upstream_current"

	printf '\nRecommendation\n'
	if [[ "$(uname -s)" != 'Darwin' ]]; then
		printf 'NVM is designed here for macOS; do not install automatically on this platform.\n'
	elif (( missing )); then
		printf 'Install prerequisites before considering NVM.\n'
	elif command -v mise >/dev/null 2>&1 || command -v asdf >/dev/null 2>&1; then
		printf 'An alternative runtime manager is already present; keep it unless you specifically need NVM.\n'
	elif ! (( upstream_current )); then
		printf 'Review upstream status or the pinned version before installing.\n'
	else
		printf 'NVM appears maintained and relevant to this repository; explicit installation is reasonable.\n'
	fi

	if ! (( upstream_current )); then
		printf 'Caveat: upstream metadata was unavailable or the pinned release needs review.\n'
	fi
	return 0
}

install_nvm() {
	if [[ "$(uname -s)" != 'Darwin' ]]; then
		printf 'Error: this installer currently supports macOS only.\n' >&2
		return 1
	fi

	check_configuration
	if [[ "$assessment_upstream_current" != '1' ]]; then
		printf 'Error: refusing to install until upstream status and the pinned version are verified.\n' >&2
		return 1
	fi
	printf '\nInstalling NVM %s\n' "$NVM_VERSION"

	for command_name in bash curl git; do
		if ! command -v "$command_name" >/dev/null 2>&1; then
			printf 'Error: required command not found: %s\n' "$command_name" >&2
			return 1
		fi
	done

	installer_file="$(mktemp)"
	trap 'rm -f "$installer_file"' RETURN
	installer_url="$NVM_RAW_BASE/install.sh"
	printf 'Downloading %s\n' "$installer_url"
	curl --fail --silent --show-error --location "$installer_url" -o "$installer_file"
	NVM_DIR="$NVM_DIR" PROFILE=/dev/null bash "$installer_file"

	if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
		printf 'Error: NVM installer completed without creating %s\n' "$NVM_DIR/nvm.sh" >&2
		return 1
	fi

	printf 'Installed NVM %s in %s\n' "$NVM_VERSION" "$NVM_DIR"
	printf 'Run: source ~/.zshrc\n'
}

command_name="${1:-check}"
case "$command_name" in
	check)
		check_configuration
		;;
	install)
		install_nvm
		;;
	-h|--help)
		usage
		;;
	*)
		usage >&2
		exit 1
		;;
esac
