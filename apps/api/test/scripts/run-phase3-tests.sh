#!/bin/bash

# @test Phase 3 - Data Model Updates - Test Runner
#
# This script runs all the tests for Phase 3 of the data model updates.
# It verifies that the OrderMetrics schema, User model, and migration script
# have been correctly implemented.

echo "Running Phase 3 Data Model Updates Tests..."
echo "============================================"

# Create helpers directory if it doesn't exist
mkdir -p ./test/helpers

# Set environment variables for testing
export NODE_ENV=test
export TEST_SUITE=phase3

# Run the unit tests
echo "Running OrderMetrics Schema Tests..."
npx jest --config test/config/jest.config.cjs ./test/unit/orderMetrics.test.cjs --verbose --detectOpenHandles --forceExit

echo "Running User Model Tests..."
npx jest --config test/config/jest.config.cjs ./test/unit/userModel.test.cjs --verbose --detectOpenHandles --forceExit

echo "Running Migration Script Tests..."
npx jest --config test/config/jest.config.cjs ./test/unit/migrationScript.test.cjs --verbose --detectOpenHandles --forceExit

# Run the integration tests
echo "Running Integration Tests..."
npx jest --config test/config/jest.config.cjs ./test/integration/phase3Integration.test.cjs --verbose --detectOpenHandles --forceExit

# Check if all tests passed
if [ $? -eq 0 ]; then
  echo "============================================"
  echo "✅ All Phase 3 tests passed!"
  echo "The OrderMetrics schema, User model, and migration script have been correctly implemented."
  exit 0
else
  echo "============================================"
  echo "❌ Some Phase 3 tests failed."
  echo "Please check the test output for details."
  exit 1
fi 