#!/bin/bash
# ------------------------------------------------------------------------------
# Flatten and Push Script for Flow-Ting's Inboxia Backend
#
# This script:
# 1. Recursively finds and flattens nested "inboxia-backend" directories (excluding the outermost).
# 2. Sets the remote URL to Flow-Ting's repository.
# 3. Stages all files, commits with a message, and pushes the changes.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
# Step 1: Flatten nested "inboxia-backend" directories
echo "Flattening nested directories..."
# This finds any directory named "inboxia-backend" that is at least two levels deep
find . -type d -name "inboxia-backend" -mindepth 2 -exec sh -c '
for d; do
  echo "Flattening: $d"
  parent=$(dirname "$d")
  # Move all files from the nested folder to its parent; ignore errors if files exist
  mv "$d"/* "$parent"/ 2>/dev/null
  # Remove the empty directory
  rmdir "$d" 2>/dev/null
done
' sh {} +

# Step 2: Set the Git remote URL to Flow-Ting's repository
echo "Setting remote to Flow-Ting's repository..."
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

# Step 3: Stage all files in the repository
echo "Staging all files..."
git add --all

# Step 4: Commit the changes
read -p "Enter commit message (or press Enter for default): " commitMessage
if [ -z "$commitMessage" ]; then
  commitMessage="Flattened repository structure and updated all files via automation script"
fi
echo "Committing changes..."
git commit -m "$commitMessage"

# Step 5: Push changes to GitHub
echo "Pushing changes to Flow-Ting's repository..."
git push -u origin main

echo "Flatten and push process complete. Your entire repository has been updated on GitHub."
