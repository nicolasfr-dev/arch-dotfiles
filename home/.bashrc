#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias zed="zeditor"
export PATH="$HOME/.local/bin:$PATH"

# Android SDK (Expo/React Native)
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
alias mypaint='flatpak run org.mypaint.MyPaint'

# Ferramentas de terminal (eza, bat, fzf, zoxide...) - ver ~/.dotfiles/shell/tools.sh
[[ -f "$HOME/.dotfiles/shell/tools.sh" ]] && source "$HOME/.dotfiles/shell/tools.sh"
