#!/bin/sh
# Install this mod into the user's Minetest directory by copying every
# non-hidden file and folder from the script's own directory into
# ~/.minetest/mods/leo_mcl_addons/. Hidden entries (those beginning with a
# dot, e.g. .git) are skipped because the shell's * glob never matches them.
set -eu

# Absolute path of the directory this script lives in.
SRC_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Destination mod folder; mkdir -p also creates ~/.minetest and .../mods.
DEST_DIR="$HOME/.minetest/mods/leo_mcl_addons"

mkdir -p "$DEST_DIR"

for entry in "$SRC_DIR"/*; do
	# Guard against an empty source directory leaving the literal glob.
	[ -e "$entry" ] || continue
	cp -R "$entry" "$DEST_DIR/"
done

echo "Installed leo_mcl_addons into: $DEST_DIR"
