# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# Completions
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Homebrew
if (( $+commands[brew] )); then
  HOMEBREW_PREFIX="$(brew --prefix)"
elif [[ -d /opt/homebrew ]]; then
  HOMEBREW_PREFIX=/opt/homebrew
elif [[ -d /usr/local ]]; then
  HOMEBREW_PREFIX=/usr/local
fi

# fzf
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi

# jj completions
if (( $+commands[jj] )); then
  source <(jj util completion zsh)
fi

# Plugins (via Homebrew)
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  [[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# PATH
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  [[ -d "$HOMEBREW_PREFIX/opt/ruby/bin" ]] && export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
  [[ -d "$HOMEBREW_PREFIX/lib/ruby/gems/3.4.0/bin" ]] && export PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.4.0/bin:$PATH"
fi
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# Options
setopt AUTO_CD

# Editor
export EDITOR=nvim

# LSP for opencode
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true

# Aliases
alias vi=nvim
alias vim=nvim
alias bat="bat --style=plain"
alias dev='cd ~/dev'
alias dotfiles='cd ~/dotfiles'
alias home='cd ~'
alias notes="cd ~/notes"
alias wip='vi ~/notes/wip/$(date "+%Y%m")-wip.md'
alias wip-list='ls -l ~/notes/wip'
alias k=kubectl
alias ..='cd ..'
alias -- -='cd -'
alias summary='vi ~/notes/summary/$(date "+%Y%m")-summary.md'
alias dlog='vi ~/dev/private/log.md'

# Functions
function dockerm() {
  docker stop "$1" && docker rm "$1"
}

function brew-sync() {
  brew update &&
  brew bundle install --cleanup --file=~/.Brewfile &&
  brew upgrade
}

function t {
  pushd $(mktemp -d /tmp/$1.XXXX)
}

function oc() {
  if [[ -f .opencode-session ]]; then
    opencode -s "$(cat .opencode-session)"
  else
    opencode
  fi
}

# Prompt with jj info
function _jj_prompt() {
  jj log -r @ --no-graph -T 'concat(change_id.shortest(), if(bookmarks, " " ++ bookmarks.join(" ")))' 2>/dev/null
}

autoload -Uz colors && colors
setopt prompt_subst
PROMPT='%F{cyan}➜%f  %F{yellow}%1~%f %F{magenta}$(_jj_prompt)%f %(?.%F{green}.%F{red})%#%f '
