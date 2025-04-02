#!/bin/bash
# ------------------------------------------------------------------------------
# Fix Entity, Clear Caches, and Run Migrations Script for Inboxia Backend
#
# This script:
# 1. Overwrites src/auth/user.entity.ts with the clean, modern ES module version.
# 2. Verifies tsconfig.json settings (manually ensure they are correct).
# 3. Removes the dist folder, node_modules cache, and any compiled .js and .js.map files in src.
# 4. Runs TypeScript compilation in noEmit mode.
# 5. Runs database migrations using ts-node with reflect-metadata preloaded.
#
# WARNING: Ensure you have a backup before running this script.
# ------------------------------------------------------------------------------
 
# Step 1: Overwrite the User entity file with the correct content
echo "Overwriting src/auth/user.entity.ts with clean code..."
cat > src/auth/user.entity.ts << 'EOF'
import "reflect-metadata";
import { Entity, PrimaryGeneratedColumn, Column } from "typeorm";

@Entity()
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column()
  tenantId: string;

  @Column({ unique: true })
  username: string;

  @Column()
  password: string;

  @Column({ default: "user" })
  role: string;
}
EOF
echo "Updated src/auth/user.entity.ts:"
cat src/auth/user.entity.ts

# Step 2: (Manual) Verify that tsconfig.json includes the necessary settings.
echo "Please ensure tsconfig.json has skipLibCheck, esModuleInterop, emitDecoratorMetadata, and experimentalDecorators set to true."

# Step 3: Clear caches and old compiled files
echo "Removing dist folder and caches..."
rm -rf dist node_modules/.cache .tscache
echo "Deleting any .js and .js.map files in the src folder..."
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
