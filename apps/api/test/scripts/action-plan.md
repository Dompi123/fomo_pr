# FOMO API Test Suite Restructuring - Action Plan

## Overview

This document outlines the remaining tasks to complete the restructuring of the FOMO API test suite. The goal is to create a more organized, maintainable, and comprehensive test suite without disrupting the existing system.

## Current Status

✅ Created a new test directory structure with clear separation of test types  
✅ Updated Jest configuration to support the new structure  
✅ Created high-quality example tests for critical functionality  
✅ Set up proper environment configuration with `.env.test`  
✅ Created test environment helpers for database connections and mocks  
✅ Updated Jest setup and teardown scripts  
✅ Added test utility functions and mocks  

## Remaining Tasks

### 1. Identify and Migrate Valuable Tests

We've identified several existing test files that need proper migration to the new structure:

| Original Path | New Path | Status |
|--------------|----------|--------|
| `test/unit/userModel.test.cjs` | `test/unit/models/User.test.cjs` | ✅ Migrated |
| `test/unit/auth.test.cjs` | `test/unit/services/Auth.test.cjs` | ⏳ Needs migration |
| `test/unit/payments.test.cjs` | `test/unit/services/Payments.test.cjs` | ⏳ Needs migration |
| `test/integration/paymentRoutes.test.cjs` | `test/integration/payment/PaymentRoutes.test.cjs` | ⏳ Needs migration |
| `test/integration/phase3Integration.test.cjs` | `test/integration/venue/VenueIntegration.test.cjs` | ⏳ Needs migration |
| `test/unit/serviceContainer.test.cjs` | Evaluate if needed | ❓ Under review |
| `test/unit/websocket.test.cjs` | `test/integration/venue/Websocket.test.cjs` | ⏳ Needs migration |

**Action items:**
1. Review each test file and determine if it should be migrated, refactored, or discarded
2. For tests to be kept, migrate them to the new structure with appropriate naming
3. For tests that require refactoring, create updated versions in the new structure

### 2. Identify Obsolete Tests

The following tests appear to be obsolete or redundant and may be candidates for removal:

- `test/unit/createService.test.cjs`
- `test/unit/memoryManager.test.cjs`
- `test/unit/websocketEnhancer.test.cjs`

**Action items:**
1. Review each potentially obsolete test to confirm it's no longer needed
2. Document reasoning for removal
3. Back up these tests in the `test-backup` directory before removal

### 3. Update NPM Scripts

The `package.json` scripts need to be updated to use the new test structure:

**Action items:**
1. Update the main `test` script to use the new configuration
2. Add specialized scripts for running different test types (unit, integration, e2e, performance)
3. Create scripts for generating and viewing test coverage reports

### 4. Documentation

**Action items:**
1. Update the README with instructions on how to run tests
2. Document the test structure and organization
3. Create guidelines for writing new tests

### 5. Implement Test Coverage

**Action items:**
1. Configure Jest to generate coverage reports
2. Set up coverage thresholds for critical code paths
3. Integrate coverage reporting with CI/CD pipeline

### 6. Testing Plan for Future Development

**Action items:**
1. Identify high-priority areas of the codebase that need additional test coverage
2. Create a schedule for implementing these tests
3. Establish best practices for test-driven development going forward

## Migration Strategy

To ensure a smooth transition without disrupting the existing system:

1. Keep the original test files in place until migration is complete
2. Run both old and new test suites in parallel during transition
3. Only remove old tests after confirming the new structure works correctly
4. Use the `test-cleanup.sh` script to automate the migration process

## Timeline

| Phase | Description | Estimated Time |
|-------|-------------|----------------|
| 1 | Complete migration of valuable tests | 2-3 days |
| 2 | Remove obsolete tests | 1 day |
| 3 | Update NPM scripts | 1 day |
| 4 | Documentation and coverage implementation | 1-2 days |
| 5 | Testing and verification | 1-2 days |

## Success Criteria

The test suite restructuring will be considered complete when:

1. All valuable tests have been migrated to the new structure
2. Test coverage meets or exceeds the previous level
3. All test types (unit, integration, e2e, performance) can be run independently
4. Documentation is complete and up-to-date
5. Developers can easily understand and extend the test suite 