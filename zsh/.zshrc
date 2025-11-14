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

# fzf
source <(fzf --zsh)

# jj completions
source <(jj util completion zsh)

# Plugins (via Homebrew)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# PATH
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
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

function wip-new() {
  local month=$(date "+%Y%m")
  local name="$1"
  local file="$HOME/notes/wip/${month}-${name}.md"
  vi "$file"
}

function brew-sync() {
  brew update &&
  brew bundle install --cleanup --file=~/.Brewfile &&
  brew upgrade
}

function t {
  pushd $(mktemp -d /tmp/$1.XXXX)
}

function release {
  local repo base existing
  case "$1" in
    h)
      repo="scopely/heimdall"
      base="master"
      ;;
    pa)
      repo="scopely/player-authx"
      base="main"
      ;;
    *)
      echo "Usage: release [h|pa]"
      echo "  h  = heimdall (develop → master)"
      echo "  pa = player-authx (develop → main)"
      return 1
      ;;
  esac

  existing=$(gh pr list --repo "$repo" --base "$base" --head develop --state open --json number -q '.[0].number')
  if [[ -n "$existing" ]]; then
    echo "Release PR already open: https://github.com/$repo/pull/$existing"
    return
  fi

  gh pr create --repo "$repo" --base "$base" --head develop \
    --title "Release $(date +%Y-%m-%d)" \
    --body "Release PR" \
    --web
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
