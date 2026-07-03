#!/bin/bash
# =============================================================================
# Bash Aliases - Search & Text
# Shortcuts für Suche und Textvergleiche
# =============================================================================

# Diff Vergleiche
alias diff_files="diff --suppress-common-lines -y"
alias compare="sdiff"
alias patch_apply="patch"

# Text Suchen rekursiv
alias txt_search="grep -rnw . -e"
alias text_find="grep -ril"

# Suche ohne Binärdateien
alias clean_find="find . -type f ! -name '*.png' ! -name '*.jpg' ! -name '*.exe' ! -name '*.o'"
