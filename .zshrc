#   -----------------------------
#   Aliases
#   -----------------------------

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

#   -----------------------------
#   Terminal colors and prompt
#   -----------------------------

export CLICOLOR=1
export LSCOLORS='GxFxCxDxBxegedabagaced'

autoload -Uz colors && colors

PROMPT='%F{cyan}%m%f:%F{green}%~%f %# '
RPROMPT='%F{yellow}%*%f'