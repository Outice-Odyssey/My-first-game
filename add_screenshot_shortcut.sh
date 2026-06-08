#!/bin/bash

set -e

SHORTCUT_NAME="Screenshot Area"
SHORTCUT_BINDING="<Super><Shift>s"
SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Pick screenshot command based on what's installed
if command -v flameshot &>/dev/null; then
    SHORTCUT_CMD="flameshot gui"
elif command -v gnome-screenshot &>/dev/null; then
    SHORTCUT_CMD="gnome-screenshot -a"
else
    echo "No screenshot tool found. Install flameshot or gnome-screenshot first."
    echo "  sudo apt install flameshot"
    exit 1
fi

# Read existing custom keybindings
existing=$(gsettings get "$SCHEMA" custom-keybindings)

# Find the next free slot number
slot=0
while [[ "$existing" == *"custom$slot/"* ]]; do
    ((slot++))
done

BINDING_PATH="$CUSTOM_BASE/custom$slot/"

# Build updated keybinding list
if [[ "$existing" == "@as []" || "$existing" == "[]" ]]; then
    new_list="['$BINDING_PATH']"
else
    # Strip trailing ] and append new entry
    new_list="${existing%]}, '$BINDING_PATH']"
fi

# Apply settings
gsettings set "$SCHEMA" custom-keybindings "$new_list"
gsettings set "$SCHEMA.custom-keybinding:$BINDING_PATH" name    "$SHORTCUT_NAME"
gsettings set "$SCHEMA.custom-keybinding:$BINDING_PATH" command "$SHORTCUT_CMD"
gsettings set "$SCHEMA.custom-keybinding:$BINDING_PATH" binding "$SHORTCUT_BINDING"

echo "Done! Shortcut added:"
echo "  Keys:    Super + Shift + S"
echo "  Command: $SHORTCUT_CMD"
echo "  Slot:    custom$slot"
