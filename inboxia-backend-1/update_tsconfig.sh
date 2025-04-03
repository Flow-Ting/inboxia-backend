#!/bin/bash
# ------------------------------------------------------------------------------
# Update tsconfig.json Module Setting Script for Inboxia Backend
#
# This script updates the "module" option in tsconfig.json to "ESNext" to ensure
# full ES module support. A backup of the original tsconfig.json is created as
# tsconfig.json.bak.
# ------------------------------------------------------------------------------
 
TSCONFIG="tsconfig.json"

if [ ! -f "$TSCONFIG" ]; then
  echo "Error: $TSCONFIG not found in the current directory."
  exit 1
fi

echo "Creating a backup of $TSCONFIG as tsconfig.json.bak..."
cp "$TSCONFIG" tsconfig.json.bak

echo "Updating the 'module' option to 'ESNext' in $TSCONFIG..."
sed -i.bak 's/"module": *"[^"]*"/"module": "ESNext"/' "$TSCONFIG"

echo "Verifying update..."
grep '"module":' "$TSCONFIG"

echo "tsconfig.json has been updated. Please review tsconfig.json to ensure all settings are correct."
