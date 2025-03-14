#!/usr/bin/env node

/**
 * Custom test runner that directly finds and runs tests
 * This bypasses config issues with Jest
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Set up paths
const apiRoot = path.resolve(__dirname, '../../');
const testDir = path.join(apiRoot, 'test');

// Function to find all test files
function findTestFiles(dir, pattern = /\.test\.cjs$/, files = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    
    if (entry.isDirectory()) {
      findTestFiles(fullPath, pattern, files);
    } else if (pattern.test(entry.name)) {
      files.push(fullPath);
    }
  }
  
  return files;
}

// Parse command line arguments
const args = process.argv.slice(2);
let testType = 'all';

if (args.includes('--unit')) {
  testType = 'unit';
} else if (args.includes('--integration')) {
  testType = 'integration';
} else if (args.includes('--e2e')) {
  testType = 'e2e';
} else if (args.includes('--performance')) {
  testType = 'performance';
}

// Find tests based on the selected type
let testFiles = [];
if (testType === 'all') {
  testFiles = findTestFiles(testDir);
} else {
  const typeDir = path.join(testDir, testType);
  if (fs.existsSync(typeDir)) {
    testFiles = findTestFiles(typeDir);
  }
}

console.log(`Found ${testFiles.length} test files of type: ${testType}`);

// Print the found test files
if (testFiles.length > 0) {
  console.log('\nTest files:');
  testFiles.forEach(file => {
    console.log(` - ${path.relative(apiRoot, file)}`);
  });
}

// Run tests if not in list-only mode
if (!args.includes('--list-only')) {
  try {
    const testPaths = testFiles.map(file => `"${file}"`).join(' ');
    const cmd = `NODE_ENV=test npx jest ${testPaths} --testEnvironment=node --config ${path.join(apiRoot, 'test/config/jest.config.cjs')}`;
    
    console.log(`\nRunning tests with command: ${cmd}\n`);
    execSync(cmd, { stdio: 'inherit', cwd: apiRoot });
    
    console.log('\nAll tests completed successfully!');
  } catch (error) {
    console.error(`\nSome tests failed with error: ${error.message}`);
    process.exit(1);
  }
} 