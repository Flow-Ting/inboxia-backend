#!/bin/bash
# ------------------------------------------------------------------------------
# Comprehensive Flatten and Preserve Script for Flow-Ting's Inboxia Backend
#
# This script renames nested "inboxia-backend" directories so that all three
# layers of your project are preserved as distinct folders. It then stages,
# commits, and pushes these changes to your GitHub repository.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
echo "Navigating to the outermost repository folder..."
cd ~/inboxia-backend || { echo "Folder ~/inboxia-backend not found!"; exit 1; }

# The expected structure is:
# ~/inboxia-backend/
# └── inboxia-backend/          <-- Outer layer
#     └── inboxia-backend/      <-- Middle layer
#         └── inboxia-backend/  <-- Innermost layer
#
# We want to rename the middle and innermost layers to preserve them.

echo "Checking for nested 'inboxia-backend' directories..."

# Rename the second layer if it exists
if [ -d "inboxia-backend/inboxia-backend" ]; then
  echo "Found second layer directory. Renaming 'inboxia-backend/inboxia-backend' to 'inboxia-backend-2'..."
  mv inboxia-backend/inboxia-backend inboxia-backend-2
else
  echo "Second layer directory not found."
fi

# Rename the third layer if it exists inside the renamed second layer
if [ -d "inboxia-backend-2/inboxia-backend" ]; then
  echo "Found third layer directory. Renaming 'inboxia-backend-2/inboxia-backend' to 'inboxia-backend-3'..."
  mv inboxia-backend-2/inboxia-backend inboxia-backend-3
else
  echo "Third layer directory not found."
fi

echo "Flattening complete. Final directory structure:"
find . -maxdepth 2 -type d -name "inboxia-backend*"

echo "Staging all changes..."
git add --all

read -p "Enter commit message (or press Enter for default): " commitMessage
if [ -z "$commitMessage" ]; then
  commitMessage="Renamed nested directories to preserve all layers"
fi

echo "Committing changes..."
git commit -m "$commitMessage"

echo "Setting remote to Flow-Ting's repository..."
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

echo "Pushing changes to GitHub..."
git push -u origin main

echo "Process complete. Your repository now contains all three layers as distinct folders on GitHub."
