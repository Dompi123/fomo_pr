#!/usr/bin/env node

/**
 * Script to update package.json scripts for the new test structure
 * 
 * This script will:
 * 1. Read the current package.json
 * 2. Update scripts to use the new test structure
 * 3. Write the updated package.json
 */

const fs = require('fs');
const path = require('path');

// Path to the package.json file
const packageJsonPath = path.join(__dirname, '../../package.json');

// Read the current package.json
console.log('Reading package.json...');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Create a backup of the original package.json
const backupPath = `${packageJsonPath}.backup-${Date.now()}`;
console.log(`Creating backup at ${backupPath}...`);
fs.writeFileSync(backupPath, JSON.stringify(packageJson, null, 2), 'utf8');

// Update the scripts
console.log('Updating scripts...');
const updatedScripts = {
  ...packageJson.scripts,
  "test": "NODE_ENV=test jest --config test/config/jest.config.cjs",
  "test:unit": "NODE_ENV=test jest --config test/config/jest.config.cjs \"test/unit/.*\\.test\\.cjs$\"",
  "test:integration": "NODE_ENV=test jest --config test/config/jest.config.cjs \"test/integration/.*\\.test\\.cjs$\"",
  "test:e2e": "NODE_ENV=test jest --config test/config/jest.config.cjs \"test/e2e/.*\\.test\\.cjs$\"",
  "test:performance": "NODE_ENV=test jest --config test/config/jest.config.cjs \"test/performance/.*\\.test\\.cjs$\"",
  "test:coverage": "NODE_ENV=test jest --config test/config/jest.config.cjs --coverage",
  "test:watch": "NODE_ENV=test jest --config test/config/jest.config.cjs --watch",
  "test:clean": "bash test/scripts/test-cleanup.sh",
  "test:smoke": "NODE_ENV=test node --experimental-json-modules test/smoke/smoke.cjs",
};

// Keep any other existing scripts that we don't want to modify
for (const key in packageJson.scripts) {
  if (!updatedScripts[key] && 
      !key.startsWith('test:') && 
      key !== 'test') {
    updatedScripts[key] = packageJson.scripts[key];
  }
}

// Update the scripts in the package.json
packageJson.scripts = updatedScripts;

// Write the updated package.json
console.log('Writing updated package.json...');
fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2), 'utf8');

console.log('Done!');
console.log(`
Updated scripts:
  "test": Run all tests
  "test:unit": Run only unit tests
  "test:integration": Run only integration tests
  "test:e2e": Run only end-to-end tests
  "test:performance": Run only performance tests
  "test:coverage": Run tests with coverage reporting
  "test:watch": Run tests in watch mode
  "test:clean": Run the test cleanup script
  "test:smoke": Run smoke tests
`);
console.log(`A backup of the original package.json has been created at ${backupPath}`); 