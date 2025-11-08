# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Paths
path+=("$HOME/.dotfiles/zoxide/bin")
path+=("$HOME/.dotfiles/fzf/bin")

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

# autosuggestions style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#b2bec3,bg=underline"

alias ll='grc ls -alh'
alias cd='z'
alias cl='clear'
alias compose='docker compose'

# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
    git
    grc
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
