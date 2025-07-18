#!/bin/bash

# Wallpaper Workspace Manager - Installation Script
# This script sets up the wallpaper workspace manager system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="wallpaper-monitor.service"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

echo "🖼️  Wallpaper Workspace Manager - Installation"
echo "=============================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Error: Do not run this script as root!"
    echo "   This is a user-level service installation."
    exit 1
fi

# Create systemd user directory
echo "📁 Creating systemd user directory..."
mkdir -p "$SYSTEMD_USER_DIR"

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x "$SCRIPT_DIR"/*.sh

# Copy service file to systemd directory
echo "📋 Installing systemd service..."
cp "$SCRIPT_DIR/$SERVICE_NAME" "$SYSTEMD_USER_DIR/"

# Update service file paths to use absolute paths
echo "🔧 Configuring service paths..."
sed -i "s|%h/wallpaper-monitor.sh|$SCRIPT_DIR/wallpaper-monitor.sh|g" "$SYSTEMD_USER_DIR/$SERVICE_NAME"

# Create wallpaper directory if it doesn't exist
echo "📂 Setting up wallpaper directory..."
mkdir -p "$HOME/Pictures/wallpapers"

# Check wallpaper directory contents
WALLPAPER_COUNT=$(find "$HOME/Pictures/wallpapers" -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | wc -l)

if [ "$WALLPAPER_COUNT" -eq 0 ]; then
    echo "⚠️  Warning: No wallpapers found in ~/Pictures/wallpapers/"
    echo "   Please add wallpapers named: 1.jpg, 2.jpg, 3.jpg, etc."
    echo "   Example:"
    echo "   cp /path/to/your/wallpaper1.jpg ~/Pictures/wallpapers/1.jpg"
    echo "   cp /path/to/your/wallpaper2.jpg ~/Pictures/wallpapers/2.jpg"
else
    echo "✅ Found $WALLPAPER_COUNT wallpaper(s) in ~/Pictures/wallpapers/"
fi

# Reload systemd and enable service
echo "🔄 Reloading systemd configuration..."
systemctl --user daemon-reload

echo "⚡ Enabling wallpaper monitor service..."
systemctl --user enable "$SERVICE_NAME"

echo "🚀 Starting wallpaper monitor service..."
systemctl --user start "$SERVICE_NAME"

# Check service status
sleep 2
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    echo "✅ Service is running successfully!"
else
    echo "❌ Service failed to start. Check status with:"
    echo "   $SCRIPT_DIR/wallpaper-service.sh status"
fi

echo ""
echo "🎉 Installation Complete!"
echo ""
echo "📋 Next Steps:"
echo "   1. Add wallpapers to ~/Pictures/wallpapers/ (1.jpg, 2.jpg, etc.)"
echo "   2. Test with: $SCRIPT_DIR/wallpaper-changer.sh"
echo "   3. Check status: $SCRIPT_DIR/wallpaper-service.sh status"
echo "   4. View logs: $SCRIPT_DIR/wallpaper-service.sh logs"
echo ""
echo "🔧 Management Commands:"
echo "   Start:   $SCRIPT_DIR/wallpaper-service.sh start"
echo "   Stop:    $SCRIPT_DIR/wallpaper-service.sh stop"
echo "   Status:  $SCRIPT_DIR/wallpaper-service.sh status"
echo "   Logs:    $SCRIPT_DIR/wallpaper-service.sh logs"
echo ""
echo "Happy workspace switching! 🚀"
