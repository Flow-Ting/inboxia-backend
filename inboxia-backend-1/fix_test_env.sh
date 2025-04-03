#!/bin/bash
# ------------------------------------------------------------------------------
# Fix Test Environment Script for Inboxia Backend
#
# This script:
# 1. Installs @types/node to ensure Node types are available.
# 2. Updates tsconfig.json to include "moduleResolution": "node" if not already set.
# 3. Clears Jest cache.
# 4. Re-runs the test suite.
#
# This helps resolve errors like:
#   "Cannot find module '@nestjs/testing'" and similar.
# ------------------------------------------------------------------------------
 
echo "Installing @types/node..."
npm install --save-dev @types/node

# Update tsconfig.json to force moduleResolution to node
TSCONFIG="tsconfig.json"
if ! grep -q '"moduleResolution": "node"' "$TSCONFIG"; then
  echo "Adding \"moduleResolution\": \"node\" to tsconfig.json..."
  # This will add the line into compilerOptions assuming it is defined as an object
  sed -i.bak -E 's/("compilerOptions": *\{)/\1\n    "moduleResolution": "node",/' "$TSCONFIG"
fi
echo "Updated tsconfig.json moduleResolution setting:"
grep '"moduleResolution":' "$TSCONFIG"

echo "Clearing Jest cache..."
npx jest --clearCache

echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
  echo "Tests still failing. Please review the error messages above."
  exit 1
fi

echo "All tests passed successfully!"
