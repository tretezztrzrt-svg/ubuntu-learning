#!/bin/bash
# =============================================================================
# Archive Functions
# Funktionen zum Komprimieren und Entpacken von Archiven
# =============================================================================

# Komprimieren mit maximalem Level
function pack_hardcore() {
    if [ $# -lt 2 ]; then
        echo "Usage: pack_hardcore <output.7z> <input>"
        return 1
    fi
    
    local output="$1"
    shift
    local input="$@"
    
    [[ "$output" != *.7z ]] && output="${output}.7z"
    
    if [ ! -e "$input" ]; then
        echo "❌ Source does not exist"
        return 1
    fi
    
    7z a -t7z -mx=9 -m0=lzma2 -ms=on "$output" "$input"
    echo "✅ Hardcore compressed: $output"
}
