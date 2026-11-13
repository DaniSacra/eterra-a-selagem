#!/usr/bin/env python3
"""Regenerates every grid in art/grids. Run: python3 tools/art/build.py"""
import importlib
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

MODULES = ["paladin", "scenery", "enemies", "morvath", "items", "font"]

if __name__ == "__main__":
    for name in MODULES:
        if os.path.exists(os.path.join(os.path.dirname(__file__), name + ".py")):
            importlib.import_module(name).build()
            print("built", name)
