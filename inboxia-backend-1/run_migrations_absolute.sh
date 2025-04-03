#!/bin/bash
# ------------------------------------------------------------------------------
# Run Migrations with Absolute Path Script for Inboxia Backend (ES Module Setup)
#
# This script:
# 1. Checks for the existence of src/data-source.ts.
# 2. Uses the absolute path for the data-source file to run database migrations.
#
# This helps resolve errors where TypeORM CLI cannot open the .ts file in an ES module environment.
# ------------------------------------------------------------------------------
 
echo "Verifying existence of src/data-source.ts..."
if [ ! -f "src/data-source.ts" ]; then
  echo "Error: src/data-source.ts not found! Please ensure it exists."
  exit 1
fi
echo "src/data-source.ts found."

# Use the absolute path to the data-source file
DATA_SOURCE="$(pwd)/src/data-source.ts"
echo "Using data-source path: $DATA_SOURCE"

echo "Running database migrations using ts-node ESM loader..."
node --loader ts-node/esm -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource "$DATA_SOURCE"
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your DATABASE_URL and entity files."
  exit 1
fi

echo "Migrations completed successfully."
