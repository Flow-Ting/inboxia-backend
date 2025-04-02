#!/bin/bash
# ------------------------------------------------------------------------------
# Check DATABASE_URL and Run Migrations Script for Inboxia Backend
#
# This script:
# 1. Checks for the .env file and loads environment variables.
# 2. Verifies that DATABASE_URL is set and prints its value.
# 3. Clears caches and old build artifacts.
# 4. Runs database migrations using ts-node with reflect-metadata preloaded.
#
# ------------------------------------------------------------------------------
 
# Step 1: Check for .env file
echo "Checking for .env file..."
if [ ! -f ".env" ]; then
    echo ".env file not found. Please create a .env file with the following format:"
    echo "DATABASE_URL=postgres://username:password@host:port/database"
    exit 1
fi

# Step 2: Load environment variables from .env
echo "Loading environment variables from .env..."
export $(grep -v '^#' .env | xargs)

# Step 3: Verify DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "DATABASE_URL is not set in your .env file. Please add it."
    exit 1
fi

echo "DATABASE_URL is set to: $DATABASE_URL"

# Step 4: Clear caches and old compiled files
echo "Clearing caches and old compiled files..."
rm -rf dist node_modules/.cache .tscache

# Step 5: Run database migrations using ts-node with reflect-metadata preloaded
echo "Running database migrations..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
    echo "Migrations failed. Please review your DATABASE_URL and entity files."
    exit 1
fi

echo "Migrations completed successfully."

