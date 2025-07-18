#!/bin/bash

# Wallpaper Workspace Manager - Uninstallation Script
# This script removes the wallpaper workspace manager system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="wallpaper-monitor.service"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

echo "🗑️  Wallpaper Workspace Manager - Uninstallation"
echo "==============================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Error: Do not run this script as root!"
    echo "   This removes a user-level service."
    exit 1
fi

# Stop and disable service
echo "🛑 Stopping wallpaper monitor service..."
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    systemctl --user stop "$SERVICE_NAME"
    echo "✅ Service stopped"
else
    echo "ℹ️  Service was not running"
fi

echo "❌ Disabling wallpaper monitor service..."
if systemctl --user is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    systemctl --user disable "$SERVICE_NAME"
    echo "✅ Service disabled"
else
    echo "ℹ️  Service was not enabled"
fi

# Remove service file
echo "🗑️  Removing systemd service file..."
if [ -f "$SYSTEMD_USER_DIR/$SERVICE_NAME" ]; then
    rm "$SYSTEMD_USER_DIR/$SERVICE_NAME"
    echo "✅ Service file removed"
else
    echo "ℹ️  Service file not found"
fi

# Reload systemd
echo "🔄 Reloading systemd configuration..."
systemctl --user daemon-reload

# Clean up log file
echo "🧹 Cleaning up log files..."
if [ -f "$HOME/.local/share/wallpaper-monitor.log" ]; then
    rm "$HOME/.local/share/wallpaper-monitor.log"
    echo "✅ Log file removed"
else
    echo "ℹ️  Log file not found"
fi

echo ""
echo "✅ Uninstallation Complete!"
echo ""
echo "📋 What was removed:"
echo "   ✅ Systemd service (stopped and disabled)"
echo "   ✅ Service configuration file"
echo "   ✅ Log files"
echo ""
echo "📋 What was kept:"
echo "   📁 Project directory: $SCRIPT_DIR"
echo "   🖼️  Wallpapers: ~/Pictures/wallpapers/"
echo ""
echo "💡 To completely remove everything:"
echo "   rm -rf $SCRIPT_DIR"
echo "   rm -rf ~/Pictures/wallpapers/  # (optional - removes your wallpapers)"
echo ""
echo "🔄 To reinstall later:"
echo "   cd $SCRIPT_DIR && ./install.sh"
