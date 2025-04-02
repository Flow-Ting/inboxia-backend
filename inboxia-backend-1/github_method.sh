#!/bin/bash
# ------------------------------------------------------------------------------
# GitHub Method Automation Script for Flow-Ting's Inboxia Backend
#
# This script:
# 1. Sets the remote URL to Flow-Ting's repository.
# 2. Stages all files in the repository.
# 3. Prompts for a commit message (or uses a default).
# 4. Commits the changes.
# 5. Pushes the changes to the main branch on GitHub.
#
# Repository: git@github.com:Flow-Ting/inboxia-backend.git
# ------------------------------------------------------------------------------

echo "Setting remote to Flow-Ting's repository..."
git remote set-url origin git@github.com:Flow-Ting/inboxia-backend.git

echo "Staging all files..."
git add --all

read -p "Enter commit message (or press Enter for default): " commitMessage
if [ -z "$commitMessage" ]; then
  commitMessage="Automated commit via GitHub method"
fi

echo "Committing changes..."
git commit -m "$commitMessage"

echo "Pushing changes to GitHub..."
git push -u origin main

echo "GitHub method complete. Your repository is now updated on GitHub."
