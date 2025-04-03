#!/bin/bash
# validate_package.sh - Validates package.json using jq

if jq . package.json > /dev/null 2>&1; then
  echo "package.json is valid."
else
  echo "Error: package.json is invalid. Please fix the syntax errors."
  exit 1
fi
