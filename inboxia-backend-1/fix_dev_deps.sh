#!/bin/bash
# ------------------------------------------------------------------------------
# Dependency Fix Script for Inboxia Backend
#
# This script:
# 1. Removes "@nestjs/schematics" from package.json since its version ^11.0.5
#    is not available.
# 2. Deletes node_modules and package-lock.json to force a clean install.
# 3. Reinstalls all dependencies.
# 4. Runs the test suite to ensure all modules are now found.
# ------------------------------------------------------------------------------
 
echo "Removing @nestjs/schematics from package.json if present..."
if grep -q '"@nestjs/schematics":' package.json; then
  sed -i.bak '/"@nestjs\/schematics":/d' package.json
  echo "Removed @nestjs/schematics."
else
  echo "@nestjs/schematics not found in package.json. Skipping removal."
fi

echo "Deleting node_modules and package-lock.json..."
rm -rf node_modules package-lock.json

echo "Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
  echo "npm install failed. Please review the error messages above."
  exit 1
fi

echo "Running tests..."
npx jest --clearCache
npm test
if [ $? -ne 0 ]; then
  echo "Tests failed. Please fix errors before proceeding."
  exit 1
fi

echo "Dependency fix complete. All modules are installed and tests passed."
