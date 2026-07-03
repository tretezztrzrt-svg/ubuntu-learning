#!/bin/bash
# =============================================================================
# Bash Aliases - Navigation & Directories
# Shortcuts für Verzeichnisnavigation
# =============================================================================

alias cd2="cd .."
alias dvd="cd ../.."

# Benutzer spezifische Verzeichnisse
alias alex="cd /home/alex/"
alias backup-logs="cd /home/alex/backup/"
alias ao-vera="cd /media/veracrypt1/"

# Admin-Kernverzeichnisse (die man täglich anfasst)
alias logs='cd /var/log'
alias conf='cd /etc'
alias srv='cd /srv'          # Oft für selbst gehostete Dienste
alias opt='cd /opt'          # Drittanbieter-Software
alias www='cd /var/www'      # Falls du Webserver verwaltest

# Temporäre Arbeitsoordner
alias work_tmp="mkdir -p ~/work_temp && cd ~/work_temp"
