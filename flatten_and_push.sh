#!/bin/bash
# ------------------------------------------------------------------------------
# Comprehensive Flattening Script for Inboxia Backend
#
# This script recursively flattens nested directories named "inboxia-backend"
# so that all project files are in one unified folder. It then stages, commits,
# and pushes the changes to the GitHub repository.
#
# WARNING: Ensure you have a backup before running this script.
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
echo "Starting recursive flattening of nested 'inboxia-backend' directories..."

# Store the current directory (should be the outermost project folder)
ROOT_DIR=$(pwd)

# Find all directories named "inboxia-backend" that are not the root directory
find . -mindepth 2 -type d -name "inboxia-backend" | while read -r nestedDir; do
  echo "Processing nested directory: $nestedDir"
  # Move all files (and subdirectories) from the nested directory to its parent directory
  mv "$nestedDir"/* "$(dirname "$nestedDir")"/
  # Attempt to remove the nested directory if empty
  if rmdir "$nestedDir" 2>/dev/null; then
    echo "Removed empty directory: $nestedDir"
  else
    echo "Directory not empty or removal failed: $nestedDir"
  fi
done

echo "Flattening complete. Final structure:"
find . -type d -name "inboxia-backend"

echo "Staging all changes..."
git add --all

read -p "Enter commit message (or press Enter for default): " commitMsg
if [ -z "$commitMsg" ]; then
  commitMsg="Flattened repository structure via automation script"
fi

echo "Committing changes..."
git commit -m "$commitMsg"

echo "Pushing changes to Flow-Ting's GitHub repository..."
git push -u origin main

echo "Flattening and push process complete. Your entire repository has been updated on GitHub."
