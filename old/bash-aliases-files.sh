#!/bin/bash
# =============================================================================
# Bash Aliases - File Management
# Shortcuts für sichere Dateioperationen
# =============================================================================

# Copy/Verschieben mit Sicherheit
alias cp_safe="cp -iv"
alias mv_safe="mv -iv"
alias rm_safe="rm -iv"
alias rmdir_safe="rm -rfiv"

# Alternative Namen
alias copy="cp_safe"
alias move="mv_safe"
alias remove="rm_safe"

# Links erstellen
alias soft_link="ln -s"
alias hard_link="ln"
