#!/bin/bash

# Wallpaper Monitor Service
# This script monitors workspace changes and triggers wallpaper changes

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
WALLPAPER_SCRIPT="$SCRIPT_DIR/wallpaper-changer.sh"
LOG_FILE="$HOME/.local/share/wallpaper-monitor.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "Wallpaper monitor service started"

# Function to get current workspace
get_current_workspace() {
    # Method 1: Try wmctrl first (most reliable on this system)
    if command -v wmctrl >/dev/null 2>&1; then
        WORKSPACE=$(wmctrl -d 2>/dev/null | grep '\*' | awk '{print $1}' 2>/dev/null)
        if [ -n "$WORKSPACE" ]; then
            echo "$WORKSPACE"
            return 0
        fi
    fi
    
    # Method 2: Try the working D-Bus method from wallpaper-changer.sh
    if command -v gdbus >/dev/null 2>&1; then
        WORKSPACE=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
            --method org.gnome.Shell.Eval 'global.get_workspace_manager().get_active_workspace_index()' 2>/dev/null | \
            awk -F"'" '{print $2}' 2>/dev/null)
        if [ -n "$WORKSPACE" ] && [ "$WORKSPACE" != "" ]; then
            echo "$WORKSPACE"
            return 0
        fi
    fi
    
    # Method 3: Try xprop (X11 only)
    if command -v xprop >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
        WORKSPACE=$(xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk '{print $3}' 2>/dev/null)
        if [ -n "$WORKSPACE" ]; then
            echo "$WORKSPACE"
            return 0
        fi
    fi
    
    # Default to workspace 0 if nothing works
    echo "0"
}

# Initialize with current workspace
LAST_WORKSPACE=$(get_current_workspace)
log_message "Initial workspace: $LAST_WORKSPACE"

# Run wallpaper changer for initial workspace
if [ -x "$WALLPAPER_SCRIPT" ]; then
    log_message "Running initial wallpaper change"
    "$WALLPAPER_SCRIPT" --service >> "$LOG_FILE" 2>&1
else
    log_message "ERROR: Wallpaper script not found or not executable: $WALLPAPER_SCRIPT"
    exit 1
fi

# Monitor workspace changes
while true; do
    sleep 0.5  # Check every half second for better responsiveness
    
    CURRENT_WORKSPACE=$(get_current_workspace)
    
    # If workspace changed, trigger wallpaper change
    if [ "$CURRENT_WORKSPACE" != "$LAST_WORKSPACE" ] && [ -n "$CURRENT_WORKSPACE" ]; then
        log_message "Workspace changed from $LAST_WORKSPACE to $CURRENT_WORKSPACE"
        
        # Small delay to ensure workspace transition is complete
        sleep 0.2
        
        # Run wallpaper changer
        if "$WALLPAPER_SCRIPT" --service >> "$LOG_FILE" 2>&1; then
            log_message "Wallpaper changed successfully for workspace $CURRENT_WORKSPACE"
        else
            log_message "ERROR: Failed to change wallpaper for workspace $CURRENT_WORKSPACE"
        fi
        
        LAST_WORKSPACE="$CURRENT_WORKSPACE"
    fi
done
