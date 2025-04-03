#!/bin/bash
# ------------------------------------------------------------------------------
# fix_local_imports.sh
#
# This script finds all TypeScript (.ts) files (excluding node_modules) and updates
# import statements for local files (starting with "./" or "../") to ensure they end
# with ".ts" if they don't already end with ".ts" or ".js".
#
# A backup of each modified file is saved with a .bak extension.
#
# ------------------------------------------------------------------------------
echo "Scanning for TypeScript files and updating local import statements..."

# Find all .ts files, excluding those in node_modules.
find . -type f -name "*.ts" ! -path "*/node_modules/*" | while read -r file; do
  # Use sed to add .ts extension if the import path starts with "./" or "../" and doesn't end in .ts or .js.
  sed -i.bak -E 's/(import\s+.*\s+from\s+["'\''])(\.{1,2}\/[^"'\''\.]+)(")/\1\2.ts\3/g' "$file"
done

echo "Local import statements have been updated. Backup files with .bak extension have been created for each modified file."
