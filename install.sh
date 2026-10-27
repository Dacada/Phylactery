#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${EMACS_CONFIG_DIR:-${HOME}/.config/emacs}"

INIT_SRC="${SCRIPT_DIR}/init.el"
EARLY_INIT_SRC="${SCRIPT_DIR}/early-init.el"
SCRATCH_FILE_SRC="${SCRIPT_DIR}/scratch.el"

# Ensure source files exist.
for file in "$INIT_SRC" "$EARLY_INIT_SRC" "SCRATCH_FILE_SRC"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Required file not found: $file" >&2
        exit 1
    fi
done

# Refuse to overwrite an existing Emacs configuration directory.
if [[ -e "$TARGET_DIR" ]]; then
    echo "Error: ${TARGET_DIR} already exists. Refusing to modify it." >&2
    exit 1
fi

mkdir -p "$TARGET_DIR"

ln -s "$INIT_SRC" "$TARGET_DIR/init.el"
ln -s "$EARLY_INIT_SRC" "$TARGET_DIR/early-init.el"
ln -s "$SCRATCH_FILE_SRC" "$TARGET_DIR/early-init.el"

echo "Created ${TARGET_DIR} and installed symlinks:"
echo "  init.el -> $INIT_SRC"
echo "  early-init.el -> $EARLY_INIT_SRC"
echo "  scratch.el -> $SCRATCH_FILE_SRC"
