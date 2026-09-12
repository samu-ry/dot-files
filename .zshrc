#   -----------------------------
#   Aliases
#   -----------------------------

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

alias reload='source ~/.zshrc'
alias path='printf "%s\n" "$PATH" | tr ":" "\n"'

#   -----------------------------
#   Terminal colors and prompt
#   -----------------------------

export CLICOLOR=1
export LSCOLORS='GxFxCxDxBxegedabagaced'

autoload -Uz colors && colors
autoload -Uz vcs_info
setopt prompt_subst

precmd_functions+=(vcs_info)
zstyle ':vcs_info:git:*' formats ' (%b)'

PROMPT='%F{cyan}%m%f:%F{green}%~%f%F{magenta}${vcs_info_msg_0_}%f %# '
RPROMPT='%F{yellow}%*%f'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion