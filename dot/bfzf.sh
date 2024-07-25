#!/bin/bash
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Yellow='\033[1;33m'
White='\033[1;37m'
NC='\033[0m'
###############################################
clear
TMP_SCRIPT=$(mktemp /tmp/countdown_script.XXXXXX)
cat << 'EOL' > "$TMP_SCRIPT"
###############################################
#!/usr/bin/env bash
#   ANSI CODE   ###############################
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Yellow='\033[1;33m'
White='\033[1;37m'
NC='\033[0m'
###############################################
abc=$(wmctrl -l|tail -n1|awk '{print $1}')
sudo /home/batan/100/bat/./toggle-decorations $abc

transset -i $abc -t

url=$(buku -p -f4 | fzf -m --reverse --preview "buku -p {1}" --preview-window=wrap | cut -f2)

if [ -n "$url" ]; then

	echo "$url" | xclip -selection clipboard
	echo "$url" | xargs firefox
fi













EOL
/usr/bin/xterm -geom 120x60+200+200 -e "sudo -u batan bash $TMP_SCRIPT"

