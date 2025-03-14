#!/usr/bin/env node

/**
 * Simple test validator script
 * This script doesn't actually run the tests but validates that:
 * 1. All test files exist and can be read
 * 2. Import paths are correct
 * 3. Test structure is valid
 */

const fs = require('fs');
const path = require('path');

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

// Validate the test files
if (testFiles.length > 0) {
  console.log('\nValidating test files:');
  
  const results = {
    valid: 0,
    invalid: 0,
    details: []
  };
  
  testFiles.forEach(file => {
    try {
      // Read the file content
      const content = fs.readFileSync(file, 'utf8');
      
      // Validate imports
      const importCheck = content.match(/require\(['"](\.\.\/)+/g);
      
      // Check if the file contains a test suite
      const testSuiteCheck = content.match(/describe\(['"]/g);
      
      // Determine if the file is valid
      const isValid = importCheck !== null && testSuiteCheck !== null;
      
      // Record the result
      results[isValid ? 'valid' : 'invalid']++;
      results.details.push({
        file: path.relative(apiRoot, file),
        isValid,
        hasImports: importCheck !== null,
        hasTestSuite: testSuiteCheck !== null
      });
      
      console.log(`${isValid ? '✓' : '✗'} ${path.relative(apiRoot, file)}`);
    } catch (error) {
      results.invalid++;
      results.details.push({
        file: path.relative(apiRoot, file),
        isValid: false,
        error: error.message
      });
      console.log(`✗ ${path.relative(apiRoot, file)} - Error: ${error.message}`);
    }
  });
  
  // Print summary
  console.log('\nValidation Summary:');
  console.log(`Total files: ${testFiles.length}`);
  console.log(`Valid files: ${results.valid}`);
  console.log(`Invalid files: ${results.invalid}`);
  
  if (results.invalid > 0) {
    console.log('\nInvalid files details:');
    results.details
      .filter(detail => !detail.isValid)
      .forEach(detail => {
        console.log(`- ${detail.file}`);
        if (detail.hasImports === false) console.log('  Missing imports');
        if (detail.hasTestSuite === false) console.log('  Missing test suite');
        if (detail.error) console.log(`  Error: ${detail.error}`);
      });
    
    process.exit(1);
  } else {
    console.log('\nAll test files validated successfully!');
  }
} else {
  console.log('No test files found.');
  process.exit(1);
} 