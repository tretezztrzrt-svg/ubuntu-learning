# search-and-find.sh

Smart, root-wide search and find functions. Skips noise directories and virtual filesystems automatically.

## Functions

### `nsearch` — Content Search

Recursively greps through files, skips binaries and junk directories.

```bash
function nsearch() {
    local pattern="$1"
    local dir="${2:-/}"

    grep -rniI \
        --exclude-dir={.git,node_modules,vendor,venv,.cache,__pycache__,dist,build,proc,sys,dev,run,snap} \
        --exclude=*.{png,jpg,jpeg,gif,svg,ico,exe,bin,o,so,pdf,zip,tar,gz} \
        "$pattern" "$dir" 2>/dev/null
}
Usage:

bash

Copy
nsearch "TODO"              # search entire filesystem
nsearch "API_KEY" /etc      # search a specific directory
sudo nsearch "password"     # search with root privileges (needed for protected files)
nfind — Filename Search
Finds files by name, prunes noise directories before descending (fast).

bash

Copy
function nfind() {
    local pattern="$1"
    local dir="${2:-/}"

    if command -v locate &>/dev/null; then
        locate -i "*$pattern*" 2>/dev/null
        return
    fi

    find "$dir" \
        \( -path '*/.git' -o -path '*/node_modules' -o -path '*/vendor' \
           -o -path '*/venv' -o -path '*/__pycache__' -o -path '*/dist' \
           -o -path '*/build' -o -path '/proc' -o -path '/sys' \
           -o -path '/dev' -o -path '/run' -o -path '/snap' \) -prune -o \
        -type f -iname "*$pattern*" -print 2>/dev/null
}
Usage:

bash

Copy
nfind "config"               # uses locate if available, else falls back to find
nfind "backup" /home         # search a specific directory (forces find, skips locate)
Notes
-I in nsearch auto-detects and skips binary files, no need to maintain an exhaustive extension list.
-prune in nfind stops find from descending into excluded directories entirely, this is significantly faster than filtering results after the fact.
Root-wide scans (/) are inherently slow on find/grep. If locate is installed and its database (updatedb) is current, prefer it for filename lookups.
2>/dev/null suppresses permission-denied noise. Run with sudo if you need results from protected paths, not just clean output.
Install
Add to ~/.bashrc:
