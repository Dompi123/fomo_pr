#!/bin/bash

# Script to fix the "No such module 'FOMO_PR'" error in Xcode

echo "Starting module fix script..."

# Step 1: Find all files that import FOMO_PR
echo "Finding files that import FOMO_PR..."
FILES_WITH_IMPORT=$(grep -l "import FOMO_PR" $(find ./FOMO_PR -name "*.swift") 2>/dev/null)

# Step 2: Update the import statements in each file
for file in $FILES_WITH_IMPORT; do
    echo "Updating imports in $file"
    
    # Replace 'import FOMO_PR' with direct imports
    sed -i '' 's/import FOMO_PR/import Foundation\nimport SwiftUI/g' "$file"
    
    # Check for duplicate import statements and remove them
    awk '!seen[$0]++' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

echo "Import statements updated in $(echo "$FILES_WITH_IMPORT" | wc -w | tr -d ' ') files."

# Step 3: Create a list of files to add to the Xcode project
echo "Creating a list of important files to include in your Xcode project..."
cat << EOF > important_files.txt
FOMO_PR/FOMOTypes.swift
FOMO_PR/FOMOImports.swift
FOMO_PR/TypesTest.swift
FOMO_PR/TypesTestEntry.swift
FOMO_PR/AppIntegration.swift
FOMO_PR/ModuleDefinition.swift
FOMO_PR/FOMOApp.swift
FOMO_PR/DirectImports.swift
EOF

echo "Important files list created. Please make sure these files are included in your Xcode project."
echo "To add them, go to File > Add Files to \"FOMO_PR\"... in Xcode."

echo "Module fix script completed!"
echo "Please follow these additional steps:"
echo "1. Clean your build folder in Xcode (Product > Clean Build Folder)"
echo "2. Close and reopen Xcode"
echo "3. Build your project again"
echo "4. If you're still having issues, please refer to the MODULE_FIX_GUIDE.md file" 