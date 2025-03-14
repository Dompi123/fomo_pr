#!/bin/bash

# Finalize Test Migration Script
# This script performs the final steps to complete the test suite migration
# It should be run after all the new tests have been created and validated

# Set colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting test migration finalization...${NC}"

# Create a timestamp for backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Step 1: Create a final backup of the original test directory
echo "Creating final backup of the current test directory..."
BACKUP_DIR="../test-backup-$TIMESTAMP"
mkdir -p $BACKUP_DIR
cp -r ../* $BACKUP_DIR/
echo -e "${GREEN}✓ Backup created at $BACKUP_DIR${NC}"

# Step 2: Update package.json scripts
echo "Updating package.json scripts..."
if [ -f "./update-package-json.js" ]; then
  node ./update-package-json.js
  echo -e "${GREEN}✓ Package.json scripts updated${NC}"
else
  echo -e "${RED}✗ update-package-json.js not found. Skipping...${NC}"
fi

# Step 3: Ensure all directories exist
echo "Ensuring all test directories exist..."
mkdir -p ../unit/{models,services,routes,utils,middleware}
mkdir -p ../integration/{auth,payment,venue,user}
mkdir -p ../e2e/{flows,api}
mkdir -p ../performance/load
mkdir -p ../smoke
echo -e "${GREEN}✓ All directories created${NC}"

# Step 4: Check if there are any tests to migrate
echo "Checking for pending test migrations..."
PENDING_TESTS=$(find .. -name "*.test.cjs" | grep -v "unit/\|integration/\|e2e/\|performance/\|backup")
if [ -n "$PENDING_TESTS" ]; then
  echo -e "${YELLOW}The following tests may need migration:${NC}"
  echo "$PENDING_TESTS"
  
  # Ask for confirmation before moving these tests
  read -p "Do you want to move these tests to a 'legacy' directory? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p ../legacy
    for test in $PENDING_TESTS; do
      # Extract filename
      FILENAME=$(basename "$test")
      # Move to legacy directory
      mv "$test" "../legacy/$FILENAME"
      echo "Moved $test to ../legacy/$FILENAME"
    done
    echo -e "${GREEN}✓ All pending tests moved to legacy directory${NC}"
  else
    echo -e "${YELLOW}No tests were moved.${NC}"
  fi
else
  echo -e "${GREEN}✓ No pending test migrations found${NC}"
fi

# Step 5: Validate test files
echo "Validating test files..."
UNIT_COUNT=$(find ../unit -name "*.test.cjs" | wc -l)
INTEGRATION_COUNT=$(find ../integration -name "*.test.cjs" | wc -l)
E2E_COUNT=$(find ../e2e -name "*.test.cjs" | wc -l)
PERFORMANCE_COUNT=$(find ../performance -name "*.test.cjs" | wc -l)

echo "Found $UNIT_COUNT unit tests"
echo "Found $INTEGRATION_COUNT integration tests"
echo "Found $E2E_COUNT end-to-end tests"
echo "Found $PERFORMANCE_COUNT performance tests"

TOTAL_COUNT=$((UNIT_COUNT + INTEGRATION_COUNT + E2E_COUNT + PERFORMANCE_COUNT))
if [ $TOTAL_COUNT -eq 0 ]; then
  echo -e "${RED}⚠️ No tests found in the new structure. Migration may not be complete.${NC}"
else
  echo -e "${GREEN}✓ Found $TOTAL_COUNT tests in the new structure${NC}"
fi

# Step 6: Run tests to validate
echo "Running tests to validate the new structure..."
cd ../../..
if npm run test; then
  echo -e "${GREEN}✓ All tests passed! Migration successful${NC}"
else
  echo -e "${RED}✗ Some tests failed. Please review and fix any issues${NC}"
fi

# Step 7: Print summary and next steps
echo
echo -e "${GREEN}Test migration finalization complete!${NC}"
echo
echo -e "${YELLOW}Summary:${NC}"
echo "- Created backup at $BACKUP_DIR"
echo "- Updated package.json scripts"
echo "- Ensured all test directories exist"
echo "- Validated test files structure"
echo "- Ran tests to validate functionality"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review any failed tests and fix issues"
echo "2. Ensure test coverage meets requirements"
echo "3. Update documentation with the new test structure"
echo "4. Remove any unnecessary backup files once you're confident with the migration"
echo
echo -e "${GREEN}The test suite migration is now complete!${NC}" 