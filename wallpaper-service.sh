#!/bin/bash

# Wallpaper Monitor Management Script

show_status() {
    echo "=== Wallpaper Monitor Service Status ==="
    systemctl --user status wallpaper-monitor.service --no-pager -l
    echo ""
    echo "=== Recent Log Entries ==="
    if [ -f "$HOME/.local/share/wallpaper-monitor.log" ]; then
        tail -10 "$HOME/.local/share/wallpaper-monitor.log"
    else
        echo "No log file found."
    fi
}

start_service() {
    echo "Starting wallpaper monitor service..."
    systemctl --user start wallpaper-monitor.service
    echo "Service started!"
}

stop_service() {
    echo "Stopping wallpaper monitor service..."
    systemctl --user stop wallpaper-monitor.service
    echo "Service stopped!"
}

restart_service() {
    echo "Restarting wallpaper monitor service..."
    systemctl --user restart wallpaper-monitor.service
    echo "Service restarted!"
}

enable_service() {
    echo "Enabling wallpaper monitor service (auto-start on login)..."
    systemctl --user enable wallpaper-monitor.service
    echo "Service enabled!"
}

disable_service() {
    echo "Disabling wallpaper monitor service..."
    systemctl --user disable wallpaper-monitor.service
    echo "Service disabled!"
}

show_logs() {
    echo "=== Live Log Monitoring (Press Ctrl+C to exit) ==="
    if [ -f "$HOME/.local/share/wallpaper-monitor.log" ]; then
        tail -f "$HOME/.local/share/wallpaper-monitor.log"
    else
        echo "No log file found."
    fi
}

case "$1" in
    status|st)
        show_status
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart|rs)
        restart_service
        ;;
    enable)
        enable_service
        ;;
    disable)
        disable_service
        ;;
    logs|log)
        show_logs
        ;;
    *)
        echo "Wallpaper Monitor Management Script"
        echo ""
        echo "Usage: $0 {status|start|stop|restart|enable|disable|logs}"
        echo ""
        echo "Commands:"
        echo "  status   - Show service status and recent logs"
        echo "  start    - Start the service"
        echo "  stop     - Stop the service" 
        echo "  restart  - Restart the service"
        echo "  enable   - Enable auto-start on login"
        echo "  disable  - Disable auto-start"
        echo "  logs     - Show live logs"
        echo ""
        echo "Current service status:"
        systemctl --user is-active wallpaper-monitor.service
        ;;
esac
