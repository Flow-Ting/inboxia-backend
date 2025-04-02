#!/bin/bash
# ------------------------------------------------------------------------------
# Rename Nested Folders and Push Script for Flow-Ting's Inboxia Backend
#
# This script renames nested "inboxia-backend" directories so that:
# - The outermost folder remains "inboxia-backend".
# - The first nested folder is renamed to "inboxia-backend-2".
# - The second nested folder (inside the first) is renamed to "inboxia-backend-3".
# Then, it stages all changes, commits with a provided message, and pushes to GitHub.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
echo "Navigating to the outermost repository folder..."
cd ~/inboxia-backend || { echo "Folder ~/inboxia-backend not found!"; exit 1; }
echo "Current directory: $(pwd)"

# Step 1: Rename the first nested folder (second layer)
if [ -d "inboxia-backend" ]; then
  echo "Renaming first nested folder to 'inboxia-backend-2'..."
  mv inboxia-backend inboxia-backend-2
else
  echo "No nested 'inboxia-backend' folder found in the outermost folder."
fi

# Step 2: Rename the nested folder inside 'inboxia-backend-2' (third layer)
if [ -d "inboxia-backend-2/inboxia-backend" ]; then
  echo "Renaming nested folder inside 'inboxia-backend-2' to 'inboxia-backend-3'..."
  mv inboxia-backend-2/inboxia-backend inboxia-backend-3
else
  echo "No third layer 'inboxia-backend' folder found inside 'inboxia-backend-2'."
fi

echo "Final directory structure:"
find . -maxdepth 2 -type d | grep -i "inboxia-backend"

# Step 3: Set the remote URL to Flow-Ting's repository
echo "Setting remote to Flow-Ting's repository..."
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

# Step 4: Stage all changes
echo "Staging all files..."
git add --all

# Step 5: Commit changes
read -p "Enter commit message (or press Enter for default): " commitMsg
if [ -z "$commitMsg" ]; then
  commitMsg="Renamed nested folders: inboxia-backend-2 and inboxia-backend-3"
fi
echo "Committing changes..."
git commit -m "$commitMsg"

# Step 6: Push changes to GitHub
echo "Pushing changes to Flow-Ting's GitHub repository..."
git push -u origin main

echo "Flatten and push process complete. Your repository now contains all layers as distinct folders."
