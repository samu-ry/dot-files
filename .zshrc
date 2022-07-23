#   -----------------------------
#   Aliases
#   -----------------------------

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

#   -----------------------------
#   Only show host name in terminal
#   -----------------------------

PS1="@%m~ %& # "

#   -----------------------------
#   Change host name color
#   -----------------------------

PROMPT='%F{cyan}%m%f:~$'