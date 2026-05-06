## Dotfiles 

- Uses Homebrew, Brewfile, and GNU Stow.
- Symlinks only `zsh`, `git`, `jj`, `nvim` and `ssh` into `$HOME`.
- Editor configs (VSCode/Cursor) are kept in `dotfiles/` but not stowed.
- Custom Codex skills live in `dotfiles/skills/`.

### Quick start
```bash
git clone https://github.com/rnaudi/dotfiles "$HOME/dotfiles"
"$HOME/dotfiles/scripts/bootstrap.sh"
```

By default, bootstrap installs missing Brewfile entries and links dotfiles. It
does not remove extra Homebrew packages or run a full upgrade unless explicitly
requested:

```bash
BOOTSTRAP_CLEANUP=1 BOOTSTRAP_UPGRADE=1 "$HOME/dotfiles/scripts/bootstrap.sh"
```

The interactive `brew-sync` shell function is intentionally stricter: it always
runs `brew bundle install --cleanup --file=~/.Brewfile` and `brew upgrade`.

### Safe checks
```bash
bash -n scripts/bootstrap.sh
bash -n scripts/doctor.sh
ruby -c Brewfile
brew bundle check --file=Brewfile --verbose
```

For a fuller local health check:

```bash
scripts/doctor.sh
```
