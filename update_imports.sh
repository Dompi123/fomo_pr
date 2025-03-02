#!/bin/bash

# Script to update import statements in Swift files
# Changes 'import Models' and 'import Network' to 'import FOMO_PR'

echo "Searching for files with 'import Models' or 'import Network'..."

# Find all Swift files with 'import Models' or 'import Network'
FILES_WITH_MODELS=$(grep -l "import Models" $(find ./FOMO_PR -name "*.swift") 2>/dev/null)
FILES_WITH_NETWORK=$(grep -l "import Network" $(find ./FOMO_PR -name "*.swift") 2>/dev/null)

# Combine the lists and remove duplicates
ALL_FILES=$(echo "$FILES_WITH_MODELS $FILES_WITH_NETWORK" | tr ' ' '\n' | sort | uniq)

# Update the import statements in each file
for file in $ALL_FILES; do
    echo "Updating imports in $file"
    
    # Replace 'import Models' with 'import FOMO_PR'
    sed -i '' 's/import Models/import FOMO_PR/g' "$file"
    
    # Replace 'import Network' with 'import FOMO_PR'
    sed -i '' 's/import Network/import FOMO_PR/g' "$file"
    
    # Replace 'import Core' with 'import FOMO_PR'
    sed -i '' 's/import Core/import FOMO_PR/g' "$file"
    
    # Check for duplicate 'import FOMO_PR' statements and remove them
    awk '!seen[$0]++' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
done

echo "Import statements updated in $(echo "$ALL_FILES" | wc -w | tr -d ' ') files."
echo "Done!" 