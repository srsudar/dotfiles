#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Strip Newlines
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗜️

# Read clipboard, strip newlines, write back
pbpaste | tr -d '\n' | pbcopy
echo "Newlines stripped from clipboard"
