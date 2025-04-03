#!/bin/bash
# ------------------------------------------------------------------------------
# Fix Imports for ESM in DataSource Script for Inboxia Backend
#
# This script updates the import statements in src/data-source.ts to include the
# .ts file extension for modules in your src directory.
#
# ------------------------------------------------------------------------------
echo "Fixing import statements in src/data-source.ts..."
sed -i.bak 's|from "./auth/user.entity"|from "./auth/user.entity.ts"|g' src/data-source.ts
echo "Import statements updated in src/data-source.ts."
