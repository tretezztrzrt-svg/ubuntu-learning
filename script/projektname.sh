#!/usr/bin/env bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "Verwendung: $0 <projektname>"
    exit 1
fi

PROJECT_NAME="$1"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"


cat > README.md <<EOF
# $PROJECT_NAME

Beschreibung folgt.
EOF

cat > LICENSE <<EOF
Just Use Ubuntu License 
Copyright (c) 2026 user:omen

Permission is granted to use, copy, modify, merge, publish, distribute, and/or sell this software, under the following extremely reasonable conditions:

    You acknowledge that Ubuntu is perfectly fine.  
    You don’t have to use it, but pretending it’s bad is strictly prohibited.

    If you break something, that’s on you.  
    The authors are not responsible for melted kernels, existential shell crises, or switching to Arch at 3 AM.

    You may fork this project, but dramatic changelogs like “rewrote everything in Rust” must be accompanied by snacks.

    No warranty whatsoever.  
    The software is provided “as is”, “as seen”, and occasionally “as cursed”.
    Use at your own risk, joy, or confusion.

By using this software, you agree that life is too short for bloated ASCII logos and that clean output is a human right.
EOF

cat > "${PROJECT_NAME}.sh" <<EOF
#!/usr/bin/env bash
# Skript für $PROJECT_NAME
echo "Hallo von $PROJECT_NAME"
EOF

chmod +x "${PROJECT_NAME}.sh"

echo -e "${GREEN}✅ Repository '$PROJECT_NAME' wurde angelegt.${NC}"
echo -e "${YELLOW}Wechsle in das Verzeichnis: cd $PROJECT_NAME${NC}"
