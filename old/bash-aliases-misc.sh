#!/bin/bash
# =============================================================================
# Bash Aliases - Miscellaneous
# Verschiedene nützliche Aliases
# =============================================================================

# Geschichte Analyse
alias his="history"
alias hg="history | grep"
alias his_last="history 20"
alias profile_me="history | awk '{print \$2}' | sort | uniq -c | sort -rn | head -10"

# Uhrzeit & Datum
alias date_now="date '+%Y-%m-%d %H:%M:%S'"

# Shutdown & Reboot
alias shutdown_now="sudo poweroff"
alias reboot_now="sudo reboot"
alias suspend_now="systemctl suspend"
alias hibernate="systemctl hibernate"

# Wichtige Shortcuts
alias help_me="man"
alias info_docs="info"
alias what_is="whatis"
alias describe="apropos"

# Terminal Tricks
alias peek="watch -n 1"
alias loop_ls="while true; do clear; ls -la; sleep 1; done"
alias watch_dir="watch -n 2 -l ls -la"
