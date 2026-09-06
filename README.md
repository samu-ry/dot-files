# dot-files

Personal dotfiles for a macOS terminal setup.

This repository stores the shell and Git configuration I use locally. The repository's `.zshrc` is the single source of truth for the interactive zsh configuration.

## Included files

- `.zshrc` - primary zsh configuration for interactive shells
- `.gitconfig` - Git color settings for diff, status, and branch output
- `install.sh` - safely installs the repository's `.zshrc` in the home directory
- `validate.sh` - checks shell syntax, formatting, and installer behavior
- `color-test.sh` - displays the terminal colors used by the configuration
- `LICENSE` - MIT License

## Terminal setup

On modern macOS, zsh is the default shell. The main terminal configuration should live in `.zshrc`.

## Install the zsh configuration

From the repository directory, run:

```bash
./install.sh
source ~/.zshrc
```

The installer creates `~/.zshrc` as a symlink to this repository's `.zshrc`. If a real `~/.zshrc` already exists, it moves it to a timestamped backup before creating the link. Running the installer again is safe when the link is already correct.

The installer also supports:

```bash
./install.sh check
./install.sh remove
./install.sh restore
./install.sh git
```

`check` reports whether `~/.zshrc` points to this repository. `remove` removes only that matching symlink; it does not remove an unrelated `.zshrc`. `restore` removes the repository symlink and restores the newest `.zshrc.backup.*` file. `git` configures Git to include this repository's `.gitconfig` using its current absolute path.

After changing `.zshrc` in this repository, update the current terminal with:

```bash
source ~/.zshrc
```

New terminal windows load the updated configuration automatically. To receive changes made on another machine, update the repository first, then reinstall if needed:

```bash
git pull
./install.sh
```

This repository no longer includes a `.bash_profile`; macOS uses zsh by default. Bash-specific configuration should be maintained separately if you need it.

## Test terminal colors

Run this from the repository directory:

```bash
./color-test.sh
```

It displays ANSI colors, the prompt colors, and macOS `ls` colors. Use it with your normal Terminal profile and any profile you are considering.

## Validate changes

Run the repository checks after editing shell configuration or the installer:

```bash
./validate.sh
```

This checks Bash and zsh syntax, Git whitespace errors, and installation behavior in a temporary home directory. It does not modify your real `~/.zshrc`. Interactive output uses green `OK` and red `FAIL` labels; redirected output is plain text. Set `NO_COLOR=1` to explicitly disable colors:

```bash
NO_COLOR=1 ./validate.sh
```

## Git configuration

The Git color file is optional. To configure it globally on the current Mac, run this from the repository directory:

```bash
./install.sh git
```

This writes the repository's current absolute path into your global Git config. Run it once on each Mac, or run it again if the repository moves. It keeps the Git UI consistent with the terminal color scheme and makes status, branch, and diff output easier to scan.

## Outside-the-repository setup

- The repository must exist at a stable path because `~/.zshrc` will point to it.
- Run `./install.sh` once on each Mac or user account where the configuration should be active.
- Run `./install.sh git` once on each Mac or user account where the Git colors should be active.
- Keep the repository's scripts executable; Git preserves those permissions.
- Use a dark macOS Terminal profile with readable text so the cyan, green, and yellow prompt colors remain visible.
- No Terminal.app setting or system-wide permission change is required.

The terminal colors are intentionally simple and readable for a dark default profile. These settings are a personal baseline and can be adjusted over time.
