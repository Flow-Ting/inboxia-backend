#!/bin/bash
# ------------------------------------------------------------------------------
# Final Production Deployment Script for Inboxia Backend (NodeNext ESM)
#
# This script performs the following steps:
# 1. Pulls the latest code from GitHub.
# 2. Installs dependencies.
# 3. Clears caches and old build artifacts.
# 4. Runs the automated test suite.
# 5. Runs database migrations using a custom migration runner.
# 6. Builds the project (transpiles TypeScript to JavaScript).
# 7. Optionally builds a production Docker image.
# 8. Starts the production server.
#
# Prerequisites:
# - package.json must include "type": "module".
# - tsconfig.json must be updated to include:
#       "module": "NodeNext",
#       "moduleResolution": "node",
#       "experimentalDecorators": true,
#       "emitDecoratorMetadata": true,
#       "esModuleInterop": true,
#       "skipLibCheck": true,
#       "target": "es2017",
#       "outDir": "./dist",
#       "types": ["node", "jest"]
# - A .env file exists with your DATABASE_URL (e.g., postgres://inboxia:Kazpyr99!@localhost:5432/inboxia)
# - The custom migration script is named "run_migration_custom.ts" and is located in the project root.
#
# ------------------------------------------------------------------------------
 
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
npm test
if [ $? -ne 0 ]; then
  echo "Tests failed. Fix errors before deployment."
  exit 1
fi

echo "Running custom database migrations..."
npx ts-node -r reflect-metadata run_migration_custom.ts
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
