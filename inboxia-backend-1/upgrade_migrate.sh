#!/bin/bash
# ------------------------------------------------------------------------------
# Upgrade to ESM and Run Migrations Script for Inboxia Backend
#
# This script:
# 1. Checks if package.json includes "type": "module". If not, it prompts you to add it.
# 2. Verifies that tsconfig.json has "module": "ESNext" (or "NodeNext") along with required decorators settings.
# 3. Clears caches and old compiled files.
# 4. Runs the database migrations using ts-node with reflect-metadata preloaded.
#
# ------------------------------------------------------------------------------
 
echo "Checking package.json for ESM support..."
if ! grep -q '"type": "module"' package.json; then
  echo "Please add \"type\": \"module\" to your package.json to enable ES modules."
  exit 1
fi
echo "package.json is set for ES modules."

echo "Verifying tsconfig.json module setting..."
if ! grep -q '"module": *"ESNext"' tsconfig.json && ! grep -q '"module": *"NodeNext"' tsconfig.json; then
  echo "Please update tsconfig.json to have \"module\": \"ESNext\" or \"module\": \"NodeNext\"."
  exit 1
fi
echo "tsconfig.json module setting verified."
 
echo "Clearing caches and old compiled files..."
rm -rf dist node_modules/.cache .tscache
find src -type f -name "*.js" -delete
find src -type f -name "*.js.map" -delete

echo "Running TypeScript compilation (noEmit)..."
npx tsc --noEmit
if [ $? -ne 0 ]; then
  echo "TypeScript compilation failed. Please fix the errors above."
  exit 1
fi
echo "TypeScript compilation verified."

echo "Running database migrations using ts-node with reflect-metadata..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your DATABASE_URL and entity files."
  exit 1
fi

echo "Migrations completed successfully."
