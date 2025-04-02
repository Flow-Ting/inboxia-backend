#!/bin/bash
# ------------------------------------------------------------------------------
# Comprehensive Flatten and Push Script for Flow-Ting's Inboxia Backend
#
# This script renames nested "inboxia-backend" directories so that each layer
# is preserved as a distinct folder:
#   - The first nested folder becomes "inboxia-backend-1"
#   - The second nested folder becomes "inboxia-backend-2"
#   - The third nested folder becomes "inboxia-backend-3"
#
# It then stages all changes, commits with a provided (or default) message,
# and pushes to Flow-Ting's GitHub repository.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
# Step 1: Navigate to the outermost repository folder
cd ~/inboxia-backend || { echo "Folder ~/inboxia-backend not found!"; exit 1; }
echo "Current directory: $(pwd)"

# Step 2: Rename the first nested "inboxia-backend" folder to "inboxia-backend-1"
if [ -d "inboxia-backend" ]; then
  echo "Renaming outer nested folder to 'inboxia-backend-1'..."
  mv inboxia-backend inboxia-backend-1
else
  echo "No nested 'inboxia-backend' folder found in the outermost directory."
fi

# Step 3: Rename the second nested folder inside "inboxia-backend-1" to "inboxia-backend-2"
if [ -d "inboxia-backend-1/inboxia-backend" ]; then
  echo "Renaming second layer folder to 'inboxia-backend-2'..."
  mv inboxia-backend-1/inboxia-backend inboxia-backend-2
else
  echo "No second layer folder named 'inboxia-backend' found inside inboxia-backend-1."
fi

# Step 4: Rename the third nested folder inside "inboxia-backend-2" to "inboxia-backend-3"
if [ -d "inboxia-backend-2/inboxia-backend" ]; then
  echo "Renaming third layer folder to 'inboxia-backend-3'..."
  mv inboxia-backend-2/inboxia-backend inboxia-backend-3
else
  echo "No third layer folder named 'inboxia-backend' found inside inboxia-backend-2."
fi

# Step 5: Display the final directory structure for verification
echo "Final directory structure:"
find . -maxdepth 2 -type d | grep -i "inboxia-backend"

# Step 6: Set the Git remote URL to Flow-Ting's repository
echo "Setting remote to Flow-Ting's repository..."
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

# Step 7: Stage all changes
echo "Staging all files..."
git add --all

# Step 8: Commit changes
read -p "Enter commit message (or press Enter for default): " commitMsg
if [ -z "$commitMsg" ]; then
  commitMsg="Preserved all layers: inboxia-backend-1, inboxia-backend-2, and inboxia-backend-3"
fi
echo "Committing changes..."
git commit -m "$commitMsg"

# Step 9: Push changes to GitHub
echo "Pushing changes to Flow-Ting's GitHub repository..."
git push -u origin main

echo "Flatten and push process complete. Your repository now contains all layers as distinct folders."
