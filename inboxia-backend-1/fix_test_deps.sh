#!/bin/bash
# ------------------------------------------------------------------------------
# Fix Test Dependencies and Update tsconfig.json for Inboxia Backend
#
# This script:
# 1. Checks tsconfig.json for a "types" property in compilerOptions.
#    If missing or incomplete, it updates tsconfig.json to include "node" and "jest".
# 2. Clears the Jest cache.
# 3. Re-runs the test suite.
#
# This ensures TypeScript can find type declarations for @nestjs/testing,
# @nestjs/typeorm, @nestjs/jwt, and bcrypt.
# ------------------------------------------------------------------------------
 
TSCONFIG="tsconfig.json"

echo "Updating tsconfig.json to include types for node and jest..."

# Check if "types" exists in tsconfig.json
if grep -q '"types":' "$TSCONFIG"; then
  # Update the types array to include both "node" and "jest"
  sed -i.bak -E 's/"types": *\[[^]]*\]/"types": ["node", "jest"]/' "$TSCONFIG"
else
  # Insert "types": ["node", "jest"] into compilerOptions block
  sed -i.bak -E 's/("compilerOptions": *\{)/\1\n    "types": ["node", "jest"],/' "$TSCONFIG"
fi

echo "Updated tsconfig.json types:"
grep '"types":' "$TSCONFIG"

echo "Clearing Jest cache..."
npx jest --clearCache

echo "Running tests..."
npm test

if [ $? -ne 0 ]; then
  echo "Tests still failing. Please review the error messages above."
  exit 1
fi

echo "Tests passed successfully!"
