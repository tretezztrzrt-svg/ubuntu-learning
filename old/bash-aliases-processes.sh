#!/bin/bash
# =============================================================================
# Bash Aliases - Processes & Memory
# Shortcuts für Prozessmanagement und Speicheranalyse
# =============================================================================

# Prozesse anzeigen
alias ps_all="ps aux"
alias ps_ef="ps -ef"
alias ps_tree="pstree -ap"
alias proc_top="top -bn1 | head -30"

# Top Varianten
alias top_mem="top -o %MEM"
alias cpu_top="top -o %CPU"

# Alternative Process Viewer (priorisiert htop falls installiert)
alias top_cmd="command -v htop >/dev/null 2>&1 && htop || top"

# Kill Varianten
alias kill_force="kill -9"
alias kill_term="kill -15"
alias kill_hang="killall"
alias zap="kill -9"

# Prozess nach Name suchen
alias myps="ps aux | grep"

# Zombie Prozesse finden
alias zombies="ps aux | awk '\$8 ~ /Z/'"

# RAM Analyse
alias ram_used="ps aux --sort=-%mem | head -15"
alias ram_top_10="ps aux --sort=-%mem | awk 'NR<=11{print \$11,\$3,\$4}'"

# Swap nutzende Prozesse
alias swap_users="ps aux | grep '[S]'swap''"

# Memory pro Prozess detailliert
alias mem_details="cat /proc/meminfo | head -20"
