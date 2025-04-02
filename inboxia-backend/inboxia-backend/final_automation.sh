#!/bin/bash
# ------------------------------------------------------------------------------
# Final Automation Script for Inboxia Backend (GitHub Method)
#
# This script automates:
# 1. Running the test suite.
# 2. Running pending database migrations using ts-node with reflect-metadata.
# 3. Building a production Docker image.
# 4. Building the project (transpiling TypeScript to JavaScript).
# 5. Notifying the user upon successful completion.
#
# Note: Ensure that you have fixed src/auth/user.entity.ts as described.
# ------------------------------------------------------------------------------
 
echo "Step 1: Running automated tests..."
npm test
if [ $? -ne 0 ]; then
  echo "Tests failed. Please fix errors before proceeding."
  exit 1
fi

echo "Step 2: Running database migrations using ts-node with reflect-metadata..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your database configuration and entity files."
  exit 1
fi

echo "Step 3: Building production Docker image..."
docker build -t inboxia-backend:latest .
if [ $? -ne 0 ]; then
  echo "Docker build failed. Please check your Dockerfile and environment."
  exit 1
fi

echo "Step 4: Building the project (transpiling TypeScript)..."
npm run build
if [ $? -ne 0 ]; then
  echo "Build failed. Please review your TypeScript configuration."
  exit 1
fi

echo "Step 5: Final automation complete. Your project is now production-ready."
