#!/bin/bash
# ------------------------------------------------------------------------------
# Fix User Entity Script for Inboxia Backend
#
# This script removes the existing src/auth/user.entity.ts file (which is causing
# errors due to legacy code) and recreates it with the correct ES module syntax.
# It then clears caches and verifies the TypeScript compilation.
# ------------------------------------------------------------------------------

echo "Removing existing src/auth/user.entity.ts..."
rm -f src/auth/user.entity.ts

echo "Creating new src/auth/user.entity.ts with correct content..."
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

echo "Verifying new src/auth/user.entity.ts:"
cat src/auth/user.entity.ts

echo "Clearing build caches and old artifacts..."
rm -rf dist node_modules/.cache .tscache

echo "Running TypeScript compiler in noEmit mode to verify compilation..."
npx tsc --noEmit
if [ $? -ne 0 ]; then
  echo "TypeScript compilation failed. Please check the errors above."
  exit 1
fi

echo "User entity fixed and TypeScript compiles successfully."
