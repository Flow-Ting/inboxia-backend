#!/bin/bash
# ------------------------------------------------------------------------------
# Final Deployment Script for Inboxia Backend with Fallback Module Installer
#
# This script:
# 1. Pulls the latest code from GitHub.
# 2. Installs dependencies.
# 3. Clears caches and old build artifacts.
# 4. Runs tests. If tests fail due to missing modules, it explicitly installs them.
# 5. Runs database migrations using ts-node with reflect-metadata preloaded.
# 6. Builds the project (TypeScript compilation).
# 7. (Optional) Builds a Docker image.
# 8. Starts the production server.
#
# Ensure tsconfig.json includes:
#   "experimentalDecorators": true,
#   "emitDecoratorMetadata": true,
#   "esModuleInterop": true,
#   "skipLibCheck": true,
#   "module": "ESNext"
#
# And package.json includes "type": "module".
# ------------------------------------------------------------------------------
 
set -e

echo "Pulling latest code from GitHub..."
git pull origin main

echo "Installing dependencies..."
npm install

echo "Clearing caches and old build artifacts..."
rm -rf dist node_modules/.cache .tscache
find src -type f -name "*.js" -delete
find src -type f -name "*.js.map" -delete

echo "Running tests..."
npx jest --clearCache
if ! npm test; then
  echo "Tests failed. Checking for missing modules..."
  # Attempt to install missing modules
  npm install @nestjs/testing @nestjs/typeorm @nestjs/jwt bcrypt
  echo "Re-running tests after installing missing modules..."
  npx jest --clearCache
  if ! npm test; then
    echo "Tests still failing. Please review the errors above."
    exit 1
  fi
fi

echo "Tests passed."

echo "Running database migrations..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your DATABASE_URL and entity files."
  exit 1
fi

echo "Building the project (TypeScript compilation)..."
npx tsc
if [ $? -ne 0 ]; then
  echo "Build failed. Please review your TypeScript configuration."
  exit 1
fi

echo "Building production Docker image (optional)..."
if command -v docker >/dev/null 2>&1; then
  docker build -t inboxia-backend:latest .
  if [ $? -ne 0 ]; then
    echo "Docker build failed. Please check your Dockerfile and environment."
    exit 1
  fi
else
  echo "Docker not found; skipping Docker build."
fi

echo "Starting production server..."
node dist/main.js

echo "Production deployment complete. Your server is now running."
echo "Domain Verification endpoint is available at: http://localhost:3000/domain-verification/inboxia.me"
