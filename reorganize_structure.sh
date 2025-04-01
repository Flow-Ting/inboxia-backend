#!/bin/bash
# This script reorganizes the project structure by moving the contents
# of the innermost "inboxia-backend" folder to the top-level directory.
# It should be run from the top-level "inboxia-backend" directory.

if [ -d "inboxia-backend/inboxia-backend/inboxia-backend" ]; then
  echo "Detected nested structure: inboxia-backend/inboxia-backend/inboxia-backend"
  mkdir -p temp_project
  cp -r inboxia-backend/inboxia-backend/inboxia-backend/* temp_project/
  rm -rf inboxia-backend
  mv temp_project inboxia-backend
  echo "Project structure reorganized successfully."
else
  echo "No nested directories detected. Structure is already correct."
fi
