   #!/bin/bash
clear

###   UPDATE UPGRADE   ###########################################
sudo apt update && sudo apt upgrade -y
sudo mkdir -p /media/batan
sudo mkdir -p /media/batan/100 
sudo mkdir -p /media/batan/roms 
sudo mkdir -p /home/batan/.vim/templates
sudo mkdir -p /home/batan/.config/nvim/pack/plugins/start/
sudo mkdir -p /home/batan/.vim/pack/plugins/start/
sudo chown -R baan:batan /media/batan

###   VISUDO   ###################################################
echo "batan ALL=(ALL:ALL) NOPASSWD:ALL"|sudo EDITOR='tee -a' visudo

###   APT INSTALL   ##############################################
sudo apt install abook axel bleachbit buku ca-certificates conky-all cmus ddgr dialog exa fairymax falkon featherpad feh festvox-us-slt-hts ffmpeg firefox flatpak fzf gcc grub-customizer grub-imageboot i3 i3blocks i3status i3-wm isync jq kodi kodi-eventclients-* kodi-game-libretro* kodi-repository-kodi kodi-visualization-* lynx man2html mat2 megatools mpv neomutt nmcli openssh-client openssh-server pandoc pass pavucontrol pipx pulseaudio python3-pip ranger rename renameutils rofi sox libsox-fmt-all
speedtest-cli sshfs sweeper taskwarrior tesseract-ocr timewarrior tldr trash-cli tree tmux ufw vim vit vnstat w3m xcape xclip xdotool xfce4-goodies xfce4-places-plugin xfce4-pulseaudio-plugin xfce4-se* xfce4-whiskermenu-plugin xterm yad yt-dlp
clear

###   PIPX   #####################################################
pipx install pyxtermjs edge-tts eg 
pipx ensurepath

###   UFW   ######################################################
for i in $(seq 35 40); do sudo ufw allow from 192.168.1.$i;done
for i in $(seq 35 40); do sudo ufw allow to 192.168.1.$i;done
sudo ufw enable

###   FSTAB   ####################################################
sudo cat /etc/fstab >> fstab
echo "UUID=71AA-F76F /media/batan/100/ vfat defaults,noatime,noexec,nofail,uid=batan,rw,umask=0011,dmask=0011 0 0">>fstab
echo "UUID=81e1c847-7c0f-474c-a1e5-f788b95b833f /media/batan/roms ext4 noatime 0 0">>fstab
sudo mv /etc/fstab /etc/fstab.org
sudo chown root:root fstab
sudo mv fstab /etc

###   FONTS   ####################################################
git clone https://github.com/batann/fonts.git
sudo cp fonts/ttf/* /usr/share/fonts/

###   CONFIG DIR   ###############################################
git clone https://github.com/batann/config.git
for i in $(ls config);do sudo mv .config/$i .config/$i.org && sudo mv config/$i .config/$i;done 
sudo trash fonts config

###   VIM NVIM   #################################################
megacopy -l /home/batan/.vim/templates/ -r /Root/vim/templates/ --download
sudo megacopy -l /home/batan/.config/nvim/templates/ -r /Root/vim/templates/ --download
sudo chown -R batan:batan .config
sudo chown -R batan:batan 1 10 100 dot check
sudo chown -R batan:batan /home/batan/

###   FLATPAK   ##################################################
flatpak install flathub net.mullvad.MullvadBrowser -y
flatpak install flathub com.tutanota.Tutanota -y

###   REMOVE   ###################################################
sudo apt remove --purge libreoff* thunderbir* 

###   CLEAR   ####################################################
sudo apt-get autoremove --purge && sudo apt-get autoclean && sudo apt-get clean && sudo sweeper --automatic

###   EXEC SCRIPTS   #############################################
sudo -u batan bash check/bin.sh 
sudo -u batan bash check/dot.sh 
source .bashrc


###   GITHUB   ###################################################
cd /media/batan/100/github/
sudo cp -r lazy.nvim/ vimwiki/ vim-taskwarrior/ tokyonight.nvim/ telescope-fzf-native.nvim/ telescope.nvim/ \~/.config/nvim/pack/plugins/start/
sudo cp -r vim_plugins_I/* /home/batan/.vim/pack/plugins/start/
sudo cp -r nautilus-scripts /home/batan/
sudo cp -r mutt-wizard /home/batan/
cd /home/batan/

###    NAUTILUS_SCRIPTS   #########################################
echo "XDG_SESSION_TYPE='x11'" >>nautilus-scripts/install.sh
sudo chmod +x nautilus-scripts/install.sh
sudo bash nautilus-scripts/install.sh
sudo trash nautilus-scripts

###   GPG   #######################################################
full_name="batan fairdinkum"
email_address="tel.petar@gmail.com"
passphrase="Ba7an?12982"
gpg --batch --full-generate-key <<EOF
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: $full_name
    Name-Email: $email_address
    Expire-Date: 1y
    Passphrase: $passphrase
    %commit
EOF
clear
echo "GPG key generation completed. Please make sure to remember your passphrase."


###   NEO-MUTT   ##################################################
goggle_pass=""
pass init $email_address
#mw -a $email_address

###   GENERATE SSH-KEY   ##########################################

key_name="id_rsa"
key_location="$HOME/.ssh/$key_name"
ssh-keygen -t rsa -b 4096 -f "$key_location" -N ""

###   REMOTE SSH   ################################################
# Create a temporary script file
TMP_SCRIPT=$(mktemp /tmp/countdown_script.XXXXXX)
cat << 'EOL' > "$TMP_SCRIPT"
#!/usr/bin/env bash
#===============================================================================
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Yellow='\033[1;33m'
White='\033[1;37m'
NC='\033[0m'
############################################################################
# Function to configure SSH on a remote machine
configure_ssh() {
    # SSH configuration file path
    ssh_config="/etc/ssh/sshd_config"
    # Combine all SSH configuration changes into one command
    ssh -o "StrictHostKeyChecking=no" -o "PasswordAuthentication=no" "$1" "\
        sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' $ssh_config && \
        sudo sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' $ssh_config && \
        sudo service ssh restart"
}

active_ips=()
local_ip=$(hostname -I | awk '{print $1}')

for i in $(seq 35 40); do
    current_ip="192.168.1.$i"
    if [ "$current_ip" != "$local_ip" ] && ping -s90 -i1 -c1 "$current_ip" &> /dev/null; then
        active_ips+=("$current_ip")
    fi
done

for ip in "${active_ips[@]}"; do
    ssh-copy-id -i ~/.ssh/id_rsa.pub batan@"$ip"
done
clear
read -n1 -p    '           Press [any] to Continue...'
EOL
clear 
sudo chmod +x $TMP_SCRIPT
sudo -u batan bash $TMP_SCRIPT
sudo trash $TMP_SCRIPT

###      ################################	
