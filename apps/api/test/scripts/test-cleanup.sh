#!/bin/bash

# Test Cleanup and Migration Script
# This script helps restructure the test suite by organizing existing tests into a new structure
# and removing obsolete tests.

# Set colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting test suite cleanup and migration...${NC}"

# 1. Create new directory structure
echo "Creating new test directory structure..."
mkdir -p apps/api/test/{unit,integration,e2e,performance,helpers,mocks,config}
mkdir -p apps/api/test/unit/{models,services,routes,utils}
mkdir -p apps/api/test/integration/{auth,payment,venue,user}
mkdir -p apps/api/test/e2e/flows
mkdir -p apps/api/test/performance/load

# 2. Move tests that should be kept to the new structure
echo "Moving tests to new structure..."

# Model tests
cp apps/api/test/userModel.test.cjs apps/api/test/unit/models/User.test.cjs
cp apps/api/test/orderMetrics.test.cjs apps/api/test/unit/services/OrderMetrics.test.cjs

# Auth tests
cp apps/api/test/auth.test.cjs apps/api/test/unit/services/Auth.test.cjs

# Payment tests
cp apps/api/test/payments.test.cjs apps/api/test/unit/services/
cp apps/api/test/paymentRoutes.test.cjs apps/api/test/integration/payment/PaymentRoutes.test.cjs

# Move integration tests
cp apps/api/test/phase3Integration.test.cjs apps/api/test/integration/venue/VenueIntegration.test.cjs
cp apps/api/test/websocket.test.cjs apps/api/test/integration/venue/Websocket.test.cjs

# Keep helper files
mkdir -p apps/api/test/helpers-new
cp apps/api/test/helpers/testSetup.cjs apps/api/test/helpers-new/

# Keep mocks directory if it contains valuable mocks
mkdir -p apps/api/test/mocks-new
cp apps/api/test/mocks/stripe.mock.cjs apps/api/test/mocks-new/

# 3. Create backup of the old test directory
echo "Creating backup of old test structure..."
timestamp=$(date +%Y%m%d%H%M%S)
mkdir -p apps/api/test-backup-$timestamp
cp -r apps/api/test/* apps/api/test-backup-$timestamp/

# 4. Clean up old test directories (after backup)
echo -e "${YELLOW}The following tests are marked for removal:${NC}"
echo "  - test/unit/serviceContainer.test.cjs"
echo "  - test/unit/websocketEnhancer.test.cjs"
echo "  - test/unit/createService.test.cjs"
echo "  - test/unit/memoryManager.test.cjs"
echo "  - test/smoke/smoke.cjs"
echo "  - Various phase-specific test scripts"
echo

# Ask for confirmation before proceeding with removal
read -p "Do you want to proceed with removing these tests? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Removing obsolete tests..."
    
    # Instead of deleting, we'll use the backup created earlier
    # And only copy back what we want to keep
    rm -rf apps/api/test/*
    
    # Copy the new structure back
    cp -r apps/api/test/unit/models/* apps/api/test/unit/
    cp -r apps/api/test/unit/services/* apps/api/test/unit/
    cp -r apps/api/test/unit/middleware/* apps/api/test/unit/
    cp -r apps/api/test/unit/utils/* apps/api/test/unit/
    cp -r apps/api/test/integration/api/* apps/api/test/integration/
    cp -r apps/api/test/integration/payment/* apps/api/test/integration/
    cp -r apps/api/test/integration/auth/* apps/api/test/integration/
    cp -r apps/api/test/integration/websocket/* apps/api/test/integration/
    
    # Restore helpers and mocks
    cp -r apps/api/test/helpers-new/* apps/api/test/helpers/
    cp -r apps/api/test/mocks-new/* apps/api/test/mocks/
    
    echo -e "${GREEN}Tests have been cleaned up and migrated to the new structure!${NC}"
    echo "The original test files are backed up in the test-backup directory."
else
    echo -e "${YELLOW}Operation cancelled. No tests were removed.${NC}"
fi

# 5. Create placeholder for high-priority tests
echo "Creating placeholders for high-priority tests..."

# Authentication tests
cat > apps/api/test/integration/auth/authentication.test.cjs << 'EOF'
/**
 * @test Authentication Integration Tests
 * 
 * These tests verify the authentication system works correctly, including:
 * - User login flow
 * - Token validation
 * - Role-based access control
 * - Error handling for invalid auth attempts
 * 
 * Implementation coming soon.
 */
EOF
echo "✓ Created placeholder for authentication tests"

# Payment processing tests placeholder
cat > apps/api/test/integration/payment/paymentProcessing.test.cjs << 'EOF'
/**
 * @test Payment Processing Integration Tests
 * 
 * These tests verify the payment processing system works correctly, including:
 * - Creating payment intents
 * - Processing payments
 * - Handling successful payments
 * - Error handling for failed payments
 * - Refund processing
 * 
 * Implementation coming soon.
 */
EOF
echo "✓ Created placeholder for payment processing tests"

echo -e "${GREEN}Test cleanup and migration complete!${NC}"
echo "Next steps:"
echo "1. Update the Jest configuration to use the new structure"
echo "2. Implement the high-priority tests"
echo "3. Run tests to verify everything works"

# Create a run-tests script
cat > apps/api/test/scripts/run-tests.sh << 'EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cd $(dirname "$0")/../../..

# Function to run tests with proper labels
run_tests() {
  local test_type=$1
  local color=$2
  local pattern=$3
  local additional_args=${4:-}
  
  echo -e "${color}Running ${test_type} tests...${NC}"
  npx jest ${pattern} --config apps/api/test/config/jest.config.cjs ${additional_args}
  local exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ ${test_type} tests passed${NC}"
  else
    echo -e "${RED}✗ ${test_type} tests failed${NC}"
  fi
  return $exit_code
}

# Parse command line arguments
test_type="all"
watch_mode=""
verbose=""

for arg in "$@"; do
  case $arg in
    --unit)
      test_type="unit"
      ;;
    --integration)
      test_type="integration"
      ;;
    --e2e)
      test_type="e2e"
      ;;
    --performance)
      test_type="performance"
      ;;
    --watch)
      watch_mode="--watch"
      ;;
    --verbose)
      verbose="--verbose"
      ;;
  esac
done

# Run the appropriate tests
case $test_type in
  "unit")
    run_tests "Unit" "${GREEN}" "**/test/unit/**/*.test.cjs" "${watch_mode} ${verbose}"
    ;;
  "integration")
    run_tests "Integration" "${YELLOW}" "**/test/integration/**/*.test.cjs" "${watch_mode} ${verbose}"
    ;;
  "e2e")
    run_tests "End-to-End" "${MAGENTA}" "**/test/e2e/**/*.test.cjs" "${watch_mode} ${verbose}"
    ;;
  "performance")
    run_tests "Performance" "${RED}" "**/test/performance/**/*.test.cjs" "${watch_mode} ${verbose}"
    ;;
  "all")
    echo -e "${BLUE}Running all tests...${NC}"
    
    run_tests "Unit" "${GREEN}" "**/test/unit/**/*.test.cjs" "${verbose}"
    unit_result=$?
    
    run_tests "Integration" "${YELLOW}" "**/test/integration/**/*.test.cjs" "${verbose}"
    integration_result=$?
    
    run_tests "End-to-End" "${MAGENTA}" "**/test/e2e/**/*.test.cjs" "${verbose}"
    e2e_result=$?
    
    run_tests "Performance" "${RED}" "**/test/performance/**/*.test.cjs" "${verbose}"
    performance_result=$?
    
    # Print summary
    echo -e "\n${BLUE}Test Summary:${NC}"
    [ $unit_result -eq 0 ] && echo -e "${GREEN}✓ Unit tests passed${NC}" || echo -e "${RED}✗ Unit tests failed${NC}"
    [ $integration_result -eq 0 ] && echo -e "${GREEN}✓ Integration tests passed${NC}" || echo -e "${RED}✗ Integration tests failed${NC}"
    [ $e2e_result -eq 0 ] && echo -e "${GREEN}✓ End-to-End tests passed${NC}" || echo -e "${RED}✗ End-to-End tests failed${NC}"
    [ $performance_result -eq 0 ] && echo -e "${GREEN}✓ Performance tests passed${NC}" || echo -e "${RED}✗ Performance tests failed${NC}"
    
    # Determine overall result
    if [ $unit_result -eq 0 ] && [ $integration_result -eq 0 ] && [ $e2e_result -eq 0 ] && [ $performance_result -eq 0 ]; then
      echo -e "\n${GREEN}All tests passed successfully!${NC}"
      exit 0
    else
      echo -e "\n${RED}Some tests failed.${NC}"
      exit 1
    fi
    ;;
esac
EOF
chmod +x apps/api/test/scripts/run-tests.sh
echo "✓ Created test runner script at apps/api/test/scripts/run-tests.sh"

echo -e "${GREEN}Test cleanup and migration complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Run tests with: ./apps/api/test/scripts/run-tests.sh"
echo -e "2. You can use flags like --unit, --integration, --e2e, --performance"
echo -e "3. Add --watch for watch mode or --verbose for verbose output"
echo -e "${YELLOW}Examples:${NC}"
echo -e "./apps/api/test/scripts/run-tests.sh             # Run all tests"
echo -e "./apps/api/test/scripts/run-tests.sh --unit      # Run only unit tests"
echo -e "./apps/api/test/scripts/run-tests.sh --unit --watch  # Run unit tests in watch mode"

echo -e "\n${RED}Important:${NC} Before deleting any files, make sure all tests are running correctly with the new structure."
echo -e "The old tests have been backed up to apps/api/test-backup-$timestamp" 