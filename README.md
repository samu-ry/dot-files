# dot-files

Personal dotfiles for a macOS terminal setup.

This repository stores the shell and Git configuration I use locally. The repository's `.zshrc` is intended to be the single source of truth for the interactive zsh configuration.

## Included files

- `.zshrc` - primary zsh configuration for interactive shells
- `.bash_profile` - bash compatibility settings and aliases
- `.gitconfig` - Git color settings for diff, status, and branch output
- `install.sh` - safely installs the repository's `.zshrc` in the home directory

## Terminal setup

On modern macOS, zsh is the default shell. The main terminal configuration should live in `.zshrc`.

## Install the zsh configuration

From the repository directory, run:

```bash
./install.sh
source ~/.zshrc
```

The installer creates `~/.zshrc` as a symlink to this repository's `.zshrc`. If a real `~/.zshrc` already exists, it moves it to a timestamped backup before creating the link. Running the installer again is safe when the link is already correct.

After changing `.zshrc` in this repository, update the current terminal with:

```bash
source ~/.zshrc
```

New terminal windows load the updated configuration automatically. To receive changes made on another machine, update the repository first, then reinstall if needed:

```bash
git pull
./install.sh
```

If you still use bash explicitly, `.bash_profile` remains available for bash sessions. It is not loaded by zsh.

## Git configuration

The Git color file is optional. To use it globally, run this from the repository directory:

```bash
git config --global include.path "$(pwd)/.gitconfig"
```

This keeps the Git UI consistent with the terminal color scheme and makes status, branch, and diff output easier to scan.

## Outside-the-repository setup

- The repository must exist at a stable path because `~/.zshrc` will point to it.
- Run `./install.sh` once on each Mac or user account where the configuration should be active.
- Use a dark macOS Terminal profile with readable text so the cyan, green, and yellow prompt colors remain visible.
- No Terminal.app setting or system-wide permission change is required.

The terminal colors are intentionally simple and readable for a dark default profile. These settings are a personal baseline and can be adjusted over time.
