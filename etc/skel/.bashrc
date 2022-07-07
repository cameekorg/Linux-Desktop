# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls="ls --color=auto"
alias ll="ls -alF"
alias l="ls -CF"

# Terminal colors
FGBLK=$( tput setaf 0 ) # 000000
FGRED=$( tput setaf 1 ) # ff0000
FGGRN=$( tput setaf 2 ) # 00ff00
FGYLO=$( tput setaf 3 ) # ffff00
FGBLU=$( tput setaf 4 ) # 0000ff
FGMAG=$( tput setaf 5 ) # ff00ff
FGCYN=$( tput setaf 6 ) # 00ffff
FGWHT=$( tput setaf 7 ) # ffffff

BGBLK=$( tput setab 0 ) # 000000
BGRED=$( tput setab 1 ) # ff0000
BGGRN=$( tput setab 2 ) # 00ff00
BGYLO=$( tput setab 3 ) # ffff00
BGBLU=$( tput setab 4 ) # 0000ff
BGMAG=$( tput setab 5 ) # ff00ff
BGCYN=$( tput setab 6 ) # 00ffff
BGWHT=$( tput setab 7 ) # ffffff

RESET=$( tput sgr0 )
BOLDM=$( tput bold )
UNDER=$( tput smul )
REVRS=$( tput rev )

# Color bash prompt
if [ $EUID == 0 ]; then
  export PS1="\[$BOLDM\]\[$FGRED\]\u\[$FGMAG\]@\[$FGCYN\]\h \[$FGBLU\]\W\$ \[$RESET\]"
 else
  export PS1="\[$BOLDM\]\[$FGGRN\]\u\[$FGMAG\]@\[$FGCYN\]\h \[$FGBLU\]\W\$ \[$RESET\]"
fi