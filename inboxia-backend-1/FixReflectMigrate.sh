#!/bin/bash
# ------------------------------------------------------------------------------
# Fix Reflect-Metadata and Run Migrations Script for Inboxia Backend
#
# This script:
# 1. Verifies tsconfig.json settings required for decorators.
# 2. Runs a small test using ts-node to ensure Reflect.decorate and Reflect.metadata
#    are available.
# 3. Clears caches and deletes old compiled files in the src folder.
# 4. Verifies TypeScript compilation in noEmit mode.
# 5. Runs database migrations using ts-node with reflect-metadata preloaded.
#
# ------------------------------------------------------------------------------
 
# Step 1: Verify tsconfig.json settings
echo "Verifying tsconfig.json settings..."
grep -E '"experimentalDecorators": true' tsconfig.json || echo "Error: experimentalDecorators must be true."
grep -E '"emitDecoratorMetadata": true' tsconfig.json || echo "Error: emitDecoratorMetadata must be true."
grep -E '"esModuleInterop": true' tsconfig.json || echo "Error: esModuleInterop must be true."
grep -E '"skipLibCheck": true' tsconfig.json || echo "Error: skipLibCheck must be true."

# Step 2: Run a reflect-metadata test using ts-node
echo "Running reflect-metadata test using ts-node..."
cat > testReflect.ts << 'EOF'
import "reflect-metadata";
console.log("Reflect.decorate:", typeof Reflect.decorate);
console.log("Reflect.metadata:", typeof Reflect.metadata);
EOF

npx ts-node testReflect.ts
if [ $? -ne 0 ]; then
  echo "Reflect-metadata test failed. Ensure reflect-metadata is installed and imported correctly."
  rm testReflect.ts
  exit 1
fi
rm testReflect.ts

# Step 3: Clear caches and remove old compiled JavaScript files from src
echo "Clearing caches and old build artifacts..."
rm -rf dist node_modules/.cache .tscache
find src -type f -name "*.js" -delete
find src -type f -name "*.js.map" -delete

# Step 4: Verify TypeScript compilation without emitting files
echo "Verifying TypeScript compilation (noEmit)..."
npx tsc --noEmit
if [ $? -ne 0 ]; then
  echo "TypeScript compilation failed. Please fix the errors above."
  exit 1
fi
echo "TypeScript compilation verified."

# Step 5: Run database migrations using ts-node with reflect-metadata preloaded
echo "Running database migrations..."
npx ts-node --files -r ts-node/register -r reflect-metadata ./node_modules/typeorm/cli.js migration:run --dataSource src/data-source.ts
if [ $? -ne 0 ]; then
  echo "Migrations failed. Please review your DATABASE_URL and entity files."
  exit 1
fi

echo "Migrations completed successfully."
