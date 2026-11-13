#!/bin/sh
# Rebuilds the web version and serves it: tools/web.sh [port]  ->  http://localhost:8070
cd "$(dirname "$0")/.." && mkdir -p build/web && "${GODOT:-$HOME/tools/godot/godot}" --headless --path . --export-release "Web" build/web/index.html 2>&1 | grep -E "ERROR" 
cd build/web && python3 -m http.server "${1:-8070}"
