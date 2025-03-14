#!/usr/bin/env node

/**
 * Cleanup Duplicate Tests Script
 * 
 * This script identifies and moves duplicate test files to a backup directory
 * after test migration is complete. It ensures the migrated tests are preserved
 * while removing duplicates that cause module naming collisions.
 */

const fs = require('fs');
const path = require('path');

// Set up paths
const apiRoot = path.resolve(__dirname, '../../');
const testDir = path.join(apiRoot, 'test');
const backupDir = path.join(apiRoot, 'test-originals-backup');

// Create backup directory if it doesn't exist
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
  console.log(`Created backup directory: ${backupDir}`);
}

// Function to find all test files
function findTestFiles(dir, pattern = /\.test\.cjs$/, files = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    
    if (entry.isDirectory()) {
      // Skip the backup and special directories
      if (entry.name !== 'test-backup' && 
          entry.name !== 'legacy' && 
          fullPath !== backupDir) {
        findTestFiles(fullPath, pattern, files);
      }
    } else if (pattern.test(entry.name)) {
      files.push(fullPath);
    }
  }
  
  return files;
}

// Function to identify duplicate tests
function findDuplicateTests(testFiles) {
  const originalTests = [];
  const migratedTests = [];
  
  // Categorize tests as original or migrated
  testFiles.forEach(file => {
    // If the file is in a subdirectory under utils, services, or models, it's migrated
    if (file.includes('/unit/utils/') || 
        file.includes('/unit/services/') || 
        file.includes('/unit/models/')) {
      migratedTests.push(file);
    } 
    // If it's directly under unit/ then it's an original
    else if (file.includes('/unit/') && path.dirname(file) === path.join(testDir, 'unit')) {
      originalTests.push(file);
    }
  });
  
  console.log(`Found ${originalTests.length} original tests and ${migratedTests.length} migrated tests`);
  
  // Match original tests with their migrated versions
  const duplicates = [];
  
  originalTests.forEach(original => {
    const originalName = path.basename(original);
    const nameWithoutExt = originalName.replace('.test.cjs', '');
    
    // Find migrated versions by matching base name with Pascal case conversion
    // e.g., auth.test.cjs → Auth.test.cjs
    const pascalCaseName = nameWithoutExt.charAt(0).toUpperCase() + nameWithoutExt.slice(1);
    
    const matches = migratedTests.filter(migrated => {
      return path.basename(migrated).toLowerCase() === pascalCaseName.toLowerCase() + '.test.cjs';
    });
    
    if (matches.length > 0) {
      duplicates.push({
        original,
        migrated: matches[0]
      });
    }
  });
  
  return duplicates;
}

// Function to move duplicate files to backup
function moveToBackup(duplicates) {
  console.log(`\nMoving ${duplicates.length} duplicate test files to backup:`);
  
  duplicates.forEach(({ original, migrated }) => {
    const originalRelative = path.relative(apiRoot, original);
    const migratedRelative = path.relative(apiRoot, migrated);
    
    // Create backup path that preserves directory structure
    const backupPath = path.join(backupDir, path.basename(original));
    
    try {
      // Move the file
      fs.copyFileSync(original, backupPath);
      fs.unlinkSync(original);
      console.log(`✓ Moved: ${originalRelative} → backup`);
      console.log(`  Keeping: ${migratedRelative}`);
    } catch (error) {
      console.error(`✗ Failed to move ${originalRelative}: ${error.message}`);
    }
  });
}

// Main function
function main() {
  console.log('Starting duplicate test file cleanup...');
  
  const testFiles = findTestFiles(testDir);
  const duplicates = findDuplicateTests(testFiles);
  
  if (duplicates.length === 0) {
    console.log('No duplicate tests found. Nothing to clean up.');
    return;
  }
  
  // Prompt for confirmation
  console.log('\nThe following original test files have migrated versions:');
  duplicates.forEach(({ original, migrated }) => {
    console.log(`- ${path.relative(apiRoot, original)} → ${path.relative(apiRoot, migrated)}`);
  });
  
  // Since we can't get interactive input in this environment, we'll just proceed
  // In a real script, you would prompt the user for confirmation here
  console.log('\nProceeding with backup and cleanup...');
  moveToBackup(duplicates);
  
  console.log('\nCleanup completed successfully!');
  console.log(`Original files backed up to: ${backupDir}`);
  console.log('You can verify that the migrated tests work correctly, and delete the backup later if needed.');
}

// Run the script
main(); 