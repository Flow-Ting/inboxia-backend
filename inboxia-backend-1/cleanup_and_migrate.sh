#!/bin/bash
# ------------------------------------------------------------------------------
# Cleanup and Migration Script for Inboxia Backend
#
# This script:
# 1. Removes node_modules and reinstalls dependencies.
# 2. Clears compiled JavaScript files in the src folder.
# 3. Runs TypeScript compilation in noEmit mode to verify correctness.
# 4. Runs database migrations using ts-node with reflect-metadata preloaded.
#
# ------------------------------------------------------------------------------
 
echo "Removing node_modules..."
rm -rf node_modules

echo "Installing dependencies..."
npm install

echo "Clearing compiled JavaScript files in the src folder..."
find src -type f -name "*.js" -delete
find src -type f -name "*.js.map" -delete

echo "Running TypeScript compiler in noEmit mode to verify compilation..."
npx tsc --noEmit
if [ $? -ne 0 ]; then
  echo "TypeScript compilation failed. Please fix the errors above."
  exit 1
fi

echo "TypeScript compilation verified."

echo "Running database migrations using ts-node with reflect-metadata preloaded..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your database configuration and entity files."
  exit 1
fi

echo "Migrations completed successfully."
