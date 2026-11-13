#!/bin/sh
# Unit tests (GUT), headless: tools/test.sh [-gtest=res://tests/test_x.gd]
cd "$(dirname "$0")/.." && "${GODOT:-$HOME/tools/godot/godot}" --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json "$@" 2>&1 | grep -v -E "^\s*$|ALSA|alsa"
