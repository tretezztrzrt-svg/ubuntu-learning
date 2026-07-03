#!/bin/bash
# =============================================================================
# Bash Aliases - Disk & Storage
# Shortcuts für Festplattenplatz und Speicherverwaltung
# =============================================================================

alias df="df -hPT | column -t"
alias df_inodes="df -hi"
alias mount_disks="mount | column -t"
alias disk_layout="sudo fdisk -l"
alias blk_uuid="blkid"

# Alternative Namen für DF
alias platz="df -h"
alias space="df -h"
alias platte="df -h"
alias freier_platz="df -h /"

# Disk Usage Kurzformen
alias dus="du -sh *"
alias dusort="du -sh * | sort -h"
alias bigfiles="du -ah . | sort -rh | head -20"
alias largedir="du -hs /* 2>/dev/null | sort -hr"
