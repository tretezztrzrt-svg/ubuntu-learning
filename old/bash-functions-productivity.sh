#!/bin/bash
# =============================================================================
# Fun & Productivity Functions
# Funktionen für Timer und Produktivität
# =============================================================================

# Countdown timer (in seconds)
function countdown() {
    if [ -z "$1" ]; then
        echo "Usage: countdown <seconds>"
        return 1
    fi
    
    local end_time=$((SECONDS + $1))
    while [ $SECONDS -lt $end_time ]; do
        remaining=$((end_time - SECONDS))
        printf "\r⏳ Time left: %02d:%02d  " $((remaining/60)) $((remaining%60))
        sleep 1
    done
    echo -e "\n🎉 Time's up!"
    play_alert_sound 2>/dev/null || echo "(Alert sound unavailable)"
}

# Pomodoro timer (25 min work, 5 min break)
function pomodoro() {
    echo "🍅 Starting Pomodoro (25 min work)..."
    countdown 1500
    echo "☕ Break time starts now! (5 min)"
    countdown 300
    echo "🔄 Ready for another round?"
}
