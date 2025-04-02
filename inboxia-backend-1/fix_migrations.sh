#!/bin/bash
# ------------------------------------------------------------------------------
# Migration Fix Script for Inboxia Backend
#
# This script:
# 1. Clears the dist folder and any ts-node caches.
# 2. Deletes any accidental .js and .js.map files in the src directory.
# 3. Runs the database migrations using ts-node with reflect-metadata preloaded.
#
# These steps help ensure that only your up-to-date TypeScript source code is compiled,
# preventing duplicate declarations and outdated code from interfering with the migration.
# ------------------------------------------------------------------------------
 
echo "Clearing the dist folder and caches..."
rm -rf dist
rm -rf node_modules/.cache .tscache

echo "Deleting accidental JavaScript files in the src folder..."
find src -type f -name "*.js" -delete
find src -type f -name "*.js.map" -delete

echo "Running database migrations using ts-node with reflect-metadata preloaded..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts

if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your database configuration and entity files."
  exit 1
fi

echo "Migrations completed successfully."
