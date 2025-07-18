#!/bin/bash

# Function to get workspace using different methods
get_workspace() {
    # Method 1: Try GNOME Shell D-Bus (if available)
    if command -v gdbus >/dev/null 2>&1; then
        WORKSPACE=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
            --method org.gnome.Shell.Eval 'global.workspace_manager.get_active_workspace_index()' 2>/dev/null | \
            grep -o "'[0-9]*'" | tr -d "'")
        
        if [ -n "$WORKSPACE" ] && [ "$WORKSPACE" != "" ]; then
            echo "$WORKSPACE"
            return 0
        fi
    fi
    
    # Method 2: Try wmctrl (if available)
    if command -v wmctrl >/dev/null 2>&1; then
        WORKSPACE=$(wmctrl -d | grep '*' | awk '{print $1}')
        if [ -n "$WORKSPACE" ]; then
            echo "$WORKSPACE"
            return 0
        fi
    fi
    
    # Method 3: Try xprop (X11 only)
    if command -v xprop >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
        WORKSPACE=$(xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk '{print $3}')
        if [ -n "$WORKSPACE" ]; then
            echo "$WORKSPACE"
            return 0
        fi
    fi
    
    # Default to workspace 0 if nothing works
    echo "0"
}

# Function to set wallpaper using different methods
set_wallpaper() {
    local wallpaper_path="$1"
    local success=false
    
    log_output "Attempting to set wallpaper: $wallpaper_path"
    
    # Method 1: gsettings (most reliable for GNOME)
    if command -v gsettings >/dev/null 2>&1; then
        log_output "Trying gsettings..."
        # Set both light and dark mode wallpapers
        if gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path" 2>/dev/null && \
           gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper_path" 2>/dev/null; then
            log_output "✓ gsettings method succeeded (both light and dark mode)"
            success=true
        else
            log_output "✗ gsettings method failed"
        fi
    fi
    
    # Method 2: feh (popular wallpaper setter)
    if [ "$success" = false ] && command -v feh >/dev/null 2>&1; then
        log_output "Trying feh..."
        if feh --bg-scale "$wallpaper_path" 2>/dev/null; then
            log_output "✓ feh method succeeded"
            success=true
        else
            log_output "✗ feh method failed"
        fi
    fi
    
    # Method 3: nitrogen (another wallpaper setter)
    if [ "$success" = false ] && command -v nitrogen >/dev/null 2>&1; then
        log_output "Trying nitrogen..."
        if nitrogen --set-scaled "$wallpaper_path" 2>/dev/null; then
            log_output "✓ nitrogen method succeeded"
            success=true
        else
            log_output "✗ nitrogen method failed"
        fi
    fi
    
    if [ "$success" = false ]; then
        log_output "ERROR: All wallpaper setting methods failed!"
        log_output "Consider installing: gsettings, feh, or nitrogen"
        return 1
    fi
    
    return 0
}

# Main script
# Check if running from service (reduce output for service mode)
if [ "$1" = "--service" ]; then
    QUIET_MODE=true
else
    QUIET_MODE=false
fi

log_output() {
    if [ "$QUIET_MODE" = false ]; then
        echo "$1"
    fi
}

log_output "Getting current workspace..."
WORKSPACE=$(get_workspace)
log_output "Current workspace: $WORKSPACE"

WALLPAPER_NUM=$((WORKSPACE + 1))
log_output "Wallpaper number: $WALLPAPER_NUM"

WALLPAPER="$HOME/Pictures/wallpapers/$WALLPAPER_NUM.jpg"
log_output "Wallpaper path: $WALLPAPER"

# Check if wallpaper directory exists
if [ ! -d "$HOME/Pictures/wallpapers" ]; then
    log_output "ERROR: Wallpaper directory doesn't exist: $HOME/Pictures/wallpapers"
    log_output "Creating directory..."
    mkdir -p "$HOME/Pictures/wallpapers"
fi

# Check if specific wallpaper exists
if [ ! -f "$WALLPAPER" ]; then
    log_output "ERROR: Wallpaper file not found: $WALLPAPER"
    if [ "$QUIET_MODE" = false ]; then
        echo "Available wallpapers in $HOME/Pictures/wallpapers:"
        ls -la "$HOME/Pictures/wallpapers" 2>/dev/null || echo "Directory is empty or doesn't exist"
    fi
    exit 1
fi

# Set the wallpaper
if set_wallpaper "$WALLPAPER"; then
    log_output "SUCCESS: Wallpaper changed successfully!"
else
    log_output "FAILED: Could not set wallpaper"
    exit 1
fi