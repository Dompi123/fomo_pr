const fs = require('fs');
const path = require('path');
const glob = require('glob');

const REQUIRED_DIRS = [
  'FOMO_PR/FOMO_PR/App',
  'FOMO_PR/FOMO_PR/Features/Venues',
  'FOMO_PR/FOMO_PR/Features/Drinks',
  'FOMO_PR/FOMO_PR/Features/Passes',
  'FOMO_PR/FOMO_PR/Features/Profile',
  'FOMO_PR/FOMO_PR/Core/Navigation',
  'FOMO_PR/FOMO_PR/Core/Network',
  'FOMO_PR/FOMO_PR/Core/Storage',
  'FOMO_PR/FOMO_PR/Core/Payment',
  'FOMO_PR/FOMO_PR/Preview Content'
];

const FILE_PATTERNS = {
  views: '**/Views/**/*.swift',
  viewmodels: '**/ViewModels/**/*.swift',
  models: '**/Models/**/*.swift',
  tests: 'FOMO_PRTests/**/*.swift'
};

const SWIFT_REQUIRED_IMPORTS = [
  'SwiftUI',
  'Foundation'
];

const SECURITY_PATTERNS = {
  keychain_storage: /Keychain.*storage.*tokens/i,
  secure_payment: /Secure.*payment.*handling/i,
  api_key_protection: /API.*key.*protection/i
};

function checkDirectoryStructure() {
  const missingDirs = [];
  for (const dir of REQUIRED_DIRS) {
    if (!fs.existsSync(dir)) {
      missingDirs.push(dir);
    }
  }
  return missingDirs;
}

function checkFilePatterns() {
  const results = {};
  for (const [key, pattern] of Object.entries(FILE_PATTERNS)) {
    const files = glob.sync(pattern);
    results[key] = files.length;
  }
  return results;
}

function checkSwiftImports(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const missingImports = [];
  for (const imp of SWIFT_REQUIRED_IMPORTS) {
    if (!content.includes(`import ${imp}`)) {
      missingImports.push(imp);
    }
  }
  return missingImports;
}

function checkSecurityPatterns(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const results = {};
  for (const [key, pattern] of Object.entries(SECURITY_PATTERNS)) {
    results[key] = pattern.test(content);
  }
  return results;
}

function generateReport() {
  const report = [];
  report.push('# FOMO App Audit Report\n');

  // Directory Structure Check
  const missingDirs = checkDirectoryStructure();
  report.push('## Directory Structure Check');
  if (missingDirs.length === 0) {
    report.push('✅ All required directories are present');
  } else {
    report.push('❌ Missing directories:');
    missingDirs.forEach(dir => report.push(`- ${dir}`));
  }
  report.push('');

  // File Pattern Check
  const filePatterns = checkFilePatterns();
  report.push('## File Pattern Check');
  for (const [key, count] of Object.entries(filePatterns)) {
    report.push(`- ${key}: ${count} files found`);
  }
  report.push('');

  // Swift Files Check
  report.push('## Swift Files Check');
  const swiftFiles = glob.sync('**/*.swift');
  for (const file of swiftFiles) {
    const missingImports = checkSwiftImports(file);
    if (missingImports.length > 0) {
      report.push(`### ${file}`);
      report.push('Missing required imports:');
      missingImports.forEach(imp => report.push(`- ${imp}`));
    }
  }
  report.push('');

  // Security Check
  report.push('## Security Check');
  const securityFiles = glob.sync('**/Security/**/*.swift');
  for (const file of securityFiles) {
    const securityResults = checkSecurityPatterns(file);
    report.push(`### ${file}`);
    for (const [key, present] of Object.entries(securityResults)) {
      report.push(`- ${key}: ${present ? '✅' : '❌'}`);
    }
  }

  return report.join('\n');
}

// Generate and save the report
const report = generateReport();
const reportPath = 'FOMO_PR/Docs/AuditResults.md';
fs.mkdirSync(path.dirname(reportPath), { recursive: true });
fs.writeFileSync(reportPath, report);
console.log(`Audit report saved to ${reportPath}`); 