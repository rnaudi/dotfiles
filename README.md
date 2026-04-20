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
