#!/bin/bash
# =============================================================================
# Bash Aliases - Package Management
# Shortcuts für APT, Snap und Flatpak
# =============================================================================

# APT Basics
alias apt_update="sudo apt update"
alias apt_upgrade="sudo apt upgrade -y"
alias apt_full_upg="sudo apt full-upgrade -y"
alias apt_install="sudo apt install -y"
alias apt_remove="sudo apt remove -y"
alias apt_purge="sudo apt purge -y"

# APT Advanced
alias apt_clean="sudo apt autoremove -y && sudo apt autoclean && sudo apt clean"
alias apt_cache="apt-cache policy"
alias apt_search="apt search"
alias apt_show="apt show"
alias installed_pkgs="dpkg --get-selections | grep install"
alias pkgs_to_remove="apt-mark showmanual"
alias held_pkgs="apt-mark showhold"
alias broken_pkgs="sudo dpkg --configure -a"
alias fix_deps="sudo apt --fix-broken install"

# Snap Paket Manager
alias snap_find="snap find"
alias snap_inst="sudo snap install"
alias snap_rem="sudo snap remove"
alias snap_refresh="sudo snap refresh"
alias snap_list="snap list --all"
alias snap_info="snap info"
alias snaps_installed="snap list"

# Flatpak Paket Manager
alias flatpaks_search="flatpak search"
alias flatpaks_install="flatpak install"
alias flatpaks_remove="flatpak uninstall"
alias flatpaks_update="flatpak update"
alias flatpaks_list="flatpak list"
alias flathub_add="flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

# Install Presets
alias install_dev="sudo apt install build-essential git vim nano curl wget htop tmux tree"
alias install_media="sudo apt install vlc ffmpeg gimp audacity"
alias install_net="sudo apt install nmap wireshark tcpdump iproute2 net-tools"
alias install_security="sudo apt install fail2ban lynis clamav clamtk rkhunter chkrootkit"
alias install_common="sudo apt install -y micro less mc btop htop p7zip-full make git meld neofetch ranger"
