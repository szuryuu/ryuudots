#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- == *i* ]] && source /usr/share/blesh/ble.sh --noattach
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias warpon='warp-cli connect'
alias warpoff='warp-cli disconnect && systemctl restart systemd-resolved'
alias clear-cache='mv ~/.cache/spotify* ~ && mv ~/.cache/cliphist ~ && mv ~/.cache/blesh ~ && sudo rm -rf /var/cache/* ~/.cache/* && mv ~/spotify* ~/cliphist ~/blesh ~/.cache'
alias remove-unused='sudo pacman -Qdtq | sudo pacman -Rns -'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
[[ ${BLE_VERSION-} ]] && ble-attach

# Created by `pipx` on 2025-05-05 06:34:31
if [ -d "/home/sunny/.local/bin" ] && [[ ":$PATH:" != *":/home/sunny/.local/bin:"* ]]; then
    PATH="${PATH:+"$PATH:"}/home/sunny/.local/bin"
fi
