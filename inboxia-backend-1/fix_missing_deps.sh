#!/bin/bash
# ------------------------------------------------------------------------------
# Fix Missing Dependencies Script for Inboxia Backend
#
# This script:
# 1. Disables engine strict mode.
# 2. Installs missing modules and type declarations needed for testing.
# 3. Clears Jest cache and re-runs tests.
#
# This ensures that modules like @nestjs/testing, @nestjs/typeorm, @nestjs/jwt,
# and bcrypt (plus its type definitions) are available.
# ------------------------------------------------------------------------------
 
echo "Disabling engine strict mode (temporarily)..."
npm config set engine-strict false

echo "Installing missing modules and type declarations..."
npm install --save-dev @nestjs/testing
npm install --save @nestjs/typeorm @nestjs/jwt bcrypt
# For bcrypt types (if not included), install the type declarations:
npm install --save-dev @types/bcrypt

echo "Clearing Jest cache..."
npx jest --clearCache

echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
  echo "Tests still failing. Please review the error messages above."
  exit 1
fi

echo "All missing dependency issues appear resolved. Tests passed successfully."
