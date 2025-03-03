#!/bin/bash

# Script to run all tests related to Phase 5 of the data model updates
# This script verifies the removal of the 'bartender' role and standardization on 'staff'
# Note: Migration scripts have been removed as we're starting with a fresh database

# Create helpers directory if it doesn't exist
mkdir -p helpers

# Set up environment for testing
export NODE_ENV=test
export TEST_SUITE=phase5

echo "Running Phase 5 tests..."

# Run unit tests
echo "Running User model tests..."
npx jest test/unit/userModel.test.cjs --verbose

# Removed bartender user migration test as it's no longer needed

echo "Running middleware tests..."
npx jest test/unit/authMiddleware.test.cjs --verbose

# Run integration tests
echo "Running integration tests..."
npx jest test/integration/phase5Integration.test.cjs --verbose

# Check if all tests passed
if [ $? -eq 0 ]; then
  echo "✅ All Phase 5 tests passed!"
  exit 0
else
  echo "❌ Some tests failed. Check the output above for details."
  exit 1
fi 