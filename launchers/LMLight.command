#!/bin/bash
# LM Light Launcher for macOS
# Double-click to start/stop

INSTALL_DIR="$HOME/.local/lmlight"
cd "$INSTALL_DIR" 2>/dev/null || { echo "❌ LM Light not installed. Run installer first."; read -p "Press Enter to close..."; exit 1; }

set -a; [ -f .env ] && source .env; set +a

# Toggle: running → stop, not running → start
if curl -s "http://localhost:${API_PORT:-8000}/health" >/dev/null 2>&1; then
    echo "🛑 Stopping LM Light..."
    "$INSTALL_DIR/stop.sh"
    echo "✅ Stopped"
else
    echo "🚀 Starting LM Light..."
    "$INSTALL_DIR/start.sh" &

    # Wait for API
    for i in {1..30}; do
        if curl -s "http://localhost:${API_PORT:-8000}/health" >/dev/null 2>&1; then
            echo "✅ Running at http://localhost:${WEB_PORT:-3000}"
            open "http://localhost:${WEB_PORT:-3000}"
            exit 0
        fi
        sleep 1
    done
    echo "❌ Failed to start"
fi

read -p "Press Enter to close..."