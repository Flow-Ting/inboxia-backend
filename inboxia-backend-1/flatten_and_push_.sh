#!/bin/bash
# ------------------------------------------------------------------------------
# Flatten and Push Script for Flow-Ting's Inboxia Backend
#
# This script automates:
# 1. Navigating to the outermost repository folder.
# 2. Flattening nested "inboxia-backend" directories (ensuring all layers are included).
# 3. Staging all files, committing with a message, and pushing to GitHub.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
# Change to the outermost folder (adjust this path if necessary)
cd ~/inboxia-backend

# Check if there is a nested "inboxia-backend/inboxia-backend" directory
if [ -d "inboxia-backend/inboxia-backend" ]; then
  echo "Nested directory found. Flattening the structure..."
  # Move everything from the inner directory to the outer directory
  mv inboxia-backend/inboxia-backend/* inboxia-backend/
  # Remove the now-empty nested directory
  rm -rf inboxia-backend/inboxia-backend
  echo "Flattening complete."
else
  echo "No nested directory found. Proceeding with push."
fi

# Change to the repository folder that now contains all project files
cd inboxia-backend

# Set the remote URL to Flow-Ting's repository
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

# Stage all files from all layers
echo "Staging all files..."
git add --all

# Prompt for a commit message
read -p "Enter commit message (or press Enter for default): " commitMessage
if [ -z "$commitMessage" ]; then
  commitMessage="Flattened repository and updated all files via automation script"
fi

echo "Committing changes..."
git commit -m "$commitMessage"

echo "Pushing changes to Flow-Ting's GitHub repository..."
git push -u origin main

echo "Flatten and push process complete. Your entire repository has been updated on GitHub."
