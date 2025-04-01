#!/bin/bash

# Script to force update dependencies and run tests automatically

echo "Starting force update of dependencies..."
npm audit fix --force

if [ $? -ne 0 ]; then
  echo "npm audit fix --force encountered an error. Please check the logs."
  exit 1
fi

echo "Dependencies updated successfully. Running test suite..."
npm test

if [ $? -ne 0 ]; then
  echo "Tests failed after dependency update. Please review the errors."
  exit 1
fi

echo "All tests passed successfully! Your project is now updated and secure."
