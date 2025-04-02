#!/bin/bash
# ------------------------------------------------------------------------------
# Final Production Deployment Script for Inboxia Backend
#
# This script automates:
# 1. Pulling the latest code from GitHub.
# 2. Installing dependencies.
# 3. Clearing caches and build artifacts.
# 4. Running the automated test suite.
# 5. Ensuring src/data-source.ts exists (creating it if missing).
# 6. Running database migrations (using ts-node with reflect-metadata preloaded).
# 7. Building the project (transpiling TypeScript to JavaScript).
# 8. Building a production Docker image (optional).
# 9. Starting the production server.
#
# Ensure your tsconfig.json includes:
#   "skipLibCheck": true,
#   "esModuleInterop": true,
#   "emitDecoratorMetadata": true,
#   "experimentalDecorators": true
#
# ------------------------------------------------------------------------------
 
echo "Pulling latest code from GitHub..."
git pull origin main

echo "Installing dependencies..."
npm install

echo "Clearing caches and build artifacts..."
rm -rf dist node_modules/.cache .tscache

echo "Running tests..."
npx jest --clearCache
npm test
if [ $? -ne 0 ]; then
  echo "Tests failed. Fix errors before deployment."
  exit 1
fi

echo "Checking for src/data-source.ts file..."
if [ ! -f "src/data-source.ts" ]; then
  echo "src/data-source.ts not found. Creating file..."
  cat > src/data-source.ts << 'EOF'
import "reflect-metadata";
import { DataSource } from "typeorm";
import { User } from "./auth/user.entity";
import { Domain } from "./domain/domain.entity";
import { EmailMetric } from "./email/email.entity";

export const AppDataSource = new DataSource({
  type: "postgres",
  url: process.env.DATABASE_URL,
  synchronize: false,
  logging: false,
  entities: [User, Domain, EmailMetric],
  migrations: ["dist/migrations/*.js"],
  subscribers: [],
});
EOF
else
  echo "src/data-source.ts already exists."
fi

echo "Running database migrations..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your database configuration and entity files."
  exit 1
fi

echo "Building the project (TypeScript compilation)..."
npx tsc
if [ $? -ne 0 ]; then
  echo "Build failed. Please review your TypeScript configuration."
  exit 1
fi

echo "Building production Docker image (optional)..."
docker build -t inboxia-backend:latest .
if [ $? -ne 0 ]; then
  echo "Docker build failed. Please check your Dockerfile and environment."
  exit 1
fi

echo "Starting production server..."
node dist/main.js

echo "Production deployment complete."
echo "Domain Verification endpoint is available at: http://localhost:3000/domain-verification/inboxia.me"
