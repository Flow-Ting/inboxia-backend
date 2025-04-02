#!/bin/bash
# ------------------------------------------------------------------------------
# GitHub Method Automation Script for Flow-Ting's Inboxia Backend
#
# This script automates:
# 1. Setting the remote URL to Flow-Ting's repository.
# 2. Staging all files (from all nested layers).
# 3. Committing changes with a provided commit message.
# 4. Pushing the commit to the main branch.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------
 
echo "Setting remote to Flow-Ting's repository..."
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

echo "Staging all files from the complete repository..."
git add --all

read -p "Enter commit message (or press Enter for default): " commitMessage
if [ -z "$commitMessage" ]; then
  commitMessage="Automated commit via GitHub method"
fi

echo "Committing changes..."
git commit -m "$commitMessage"

echo "Pushing changes to Flow-Ting's repository..."
git push -u origin main

echo "GitHub Method process complete. Your complete repository has been pushed to Flow-Ting's GitHub."
