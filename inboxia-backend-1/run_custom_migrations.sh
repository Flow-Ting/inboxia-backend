#!/bin/bash
# ------------------------------------------------------------------------------
# Run Custom Migrations Script (Final ESM Fix)
#
# This script:
# 1. Renames run_migration_custom.ts to run_migration_custom.mts to force Node
#    to treat it as an ES module.
# 2. Runs the migration script using ts-node with ESM mode, experimental 
#    specifier resolution, and preloads reflect-metadata.
#
# ------------------------------------------------------------------------------
 
echo "Renaming run_migration_custom.ts to run_migration_custom.mts..."
if [ -f "run_migration_custom.ts" ]; then
  mv run_migration_custom.ts run_migration_custom.mts
  echo "File renamed successfully."
else
  echo "run_migration_custom.ts not found. Please check your file names."
  exit 1
fi

echo "Running custom migrations..."
npx ts-node --esm --experimental-specifier-resolution=node -r reflect-metadata run_migration_custom.mts
if [ $? -ne 0 ]; then
  echo "Custom migrations failed. Please review the error output."
  exit 1
fi

echo "Custom migrations completed successfully."
