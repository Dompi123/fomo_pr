#!/usr/bin/env node

/**
 * Script to complete the migration of tests to the new directory structure
 */

const fs = require('fs');
const path = require('path');

// Path to the api root
const apiRoot = path.resolve(__dirname, '../../');
const testDir = path.join(apiRoot, 'test');

// Test type mapping
const TEST_TYPE_MAPPING = {
  // Model tests
  'userModel.test.cjs': { 
    type: 'models', 
    newName: 'User.test.cjs' 
  },
  
  // Utility tests
  'auth.test.cjs': { 
    type: 'utils', 
    newName: 'Auth.test.cjs' 
  },
  'cacheStrategy.test.cjs': { 
    type: 'utils', 
    newName: 'CacheStrategy.test.cjs' 
  },
  'circuitBreaker.test.cjs': { 
    type: 'utils', 
    newName: 'CircuitBreaker.test.cjs' 
  },
  'memoryManager.test.cjs': { 
    type: 'utils', 
    newName: 'MemoryManager.test.cjs' 
  },
  'monitoring.test.cjs': { 
    type: 'utils', 
    newName: 'Monitoring.test.cjs' 
  },
  'websocket.test.cjs': { 
    type: 'utils', 
    newName: 'Websocket.test.cjs' 
  },
  'websocketEnhancer.test.cjs': { 
    type: 'utils', 
    newName: 'WebsocketEnhancer.test.cjs' 
  },
  'orderMetrics.test.cjs': { 
    type: 'utils', 
    newName: 'OrderMetrics.test.cjs' 
  },
  
  // Service tests
  'createService.test.cjs': { 
    type: 'services', 
    newName: 'CreateService.test.cjs' 
  },
  'serviceContainer.test.cjs': { 
    type: 'services', 
    newName: 'ServiceContainer.test.cjs' 
  },
  'serviceMetrics.test.cjs': { 
    type: 'services', 
    newName: 'ServiceMetrics.test.cjs' 
  },
  'paymentHandler.test.cjs': { 
    type: 'services', 
    newName: 'PaymentHandler.test.cjs' 
  },
  'payments.test.cjs': { 
    type: 'services', 
    newName: 'Payments.test.cjs' 
  }
};

// Function to read and update a test file with new import paths
function updateImportPaths(filePath, targetDir) {
  const content = fs.readFileSync(filePath, 'utf8');
  
  // Calculate the additional path depth for imports
  const additionalDepth = targetDir.split('/').length - 1;
  const importPrefix = '../'.repeat(additionalDepth);
  
  // Update import paths
  let updatedContent = content.replace(
    /require\(['"]\.\.\/([^'"]+)['"]\)/g, 
    `require('${importPrefix}../$1')`
  );
  
  return updatedContent;
}

// Function to migrate a single test file
function migrateTestFile(fileName, sourcePath) {
  const mapping = TEST_TYPE_MAPPING[fileName];
  if (!mapping) {
    console.log(`Skipping ${fileName} - no mapping defined`);
    return;
  }
  
  const { type, newName } = mapping;
  
  // Create the target directory if it doesn't exist
  const targetDir = path.join(testDir, 'unit', type);
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
    console.log(`Created directory: ${targetDir}`);
  }
  
  // Source and target paths
  const sourceFilePath = path.join(sourcePath, fileName);
  const targetFilePath = path.join(targetDir, newName);
  
  // Skip if target already exists and source is the same or target is newer
  if (fs.existsSync(targetFilePath)) {
    const sourceStats = fs.statSync(sourceFilePath);
    const targetStats = fs.statSync(targetFilePath);
    
    if (targetStats.mtimeMs >= sourceStats.mtimeMs) {
      console.log(`Skipping ${fileName} - target already exists and is up to date`);
      return;
    }
  }
  
  // Update the import paths in the file
  const updatedContent = updateImportPaths(sourceFilePath, path.relative(apiRoot, targetDir));
  
  // Write the updated file to the target location
  fs.writeFileSync(targetFilePath, updatedContent);
  console.log(`Migrated: ${fileName} → ${type}/${newName}`);
}

// Main migration function
function migrateTests() {
  console.log('Starting test migration...');
  
  // Process files in the unit directory
  const unitDir = path.join(testDir, 'unit');
  const files = fs.readdirSync(unitDir);
  
  for (const file of files) {
    const filePath = path.join(unitDir, file);
    const stats = fs.statSync(filePath);
    
    if (stats.isFile() && file.endsWith('.test.cjs')) {
      migrateTestFile(file, unitDir);
    }
  }
  
  console.log('Migration completed!');
}

// Run the migration
migrateTests(); 