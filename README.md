# dot-files

Personal dotfiles for a macOS terminal setup.

This repository stores the shell and Git configuration I use locally. It is intended to be copied or symlinked into the home directory so the terminal behaves consistently across new sessions.

## Included files

- `.zshrc` - primary zsh configuration for interactive shells
- `.bash_profile` - bash compatibility settings and aliases
- `.gitconfig` - Git color settings for diff, status, and branch output

## Terminal setup

On modern macOS, zsh is the default shell. The main terminal configuration should live in `.zshrc`.

Typical usage:

```bash
ln -s ~/Code/dot-files/.zshrc ~/.zshrc
source ~/.zshrc
```

If you still need bash-specific settings for compatibility or explicit bash sessions, you can also keep `.bash_profile` in sync with your shell preferences.

## Git configuration

To use the repo's Git colors globally:

```bash
git config --global include.path "/Users/rytron/Code/dot-files/.gitconfig"
```

This keeps the Git UI consistent with the terminal color scheme and makes status, branch, and diff output easier to scan.

## Notes

- The terminal colors are intentionally simple and readable for a dark default profile.
- The repo is meant for local customization rather than a packaged install.
- These settings are best treated as a personal baseline that can be adjusted over time.
