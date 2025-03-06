#!/bin/bash

# Design System Linting Script
# This script can be added as a Run Script Build Phase in Xcode to enforce design system usage.
# It will warn about direct styling usage but won't fail the build to avoid blocking development.

# Define output colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}FOMO Design System Lint${NC}"
echo "${BLUE}=======================${NC}"

# Use the SRCROOT environment variable if run from Xcode, otherwise use script location
if [ -z "$SRCROOT" ]; then
    SRCROOT="../FOMO_PR"
fi

# Run checks on the source directory
function check_pattern() {
    local pattern=$1
    local message=$2
    local exclude_pattern=${3:-"FOMOTheme"}
    
    # Find all Swift files with the pattern, excluding the design system files and those using FOMOTheme
    violations=$(find "$SRCROOT" -name "*.swift" -not -path "*/Core/Design/*" | xargs grep -l "$pattern" | xargs grep -L "$exclude_pattern" 2>/dev/null || echo "")
    
    if [ -n "$violations" ]; then
        violation_count=$(echo "$violations" | wc -l | tr -d ' ')
        echo "${YELLOW}Found $violation_count files with $message${NC}"
        
        # Show up to 3 examples
        echo "$violations" | head -3 | while read -r file; do
            relative_path=$(echo "$file" | sed "s|$SRCROOT/||")
            echo "${YELLOW}- $relative_path${NC}"
            
            # Show one example violation from the file
            example=$(grep -n "$pattern" "$file" | head -1)
            line_number=$(echo "$example" | cut -d: -f1)
            echo "  Line $line_number: $(echo "$example" | cut -d: -f2- | sed 's/^[ \t]*//')"
        done
        
        # If there are more files, show a count
        remaining=$((violation_count - 3))
        if [ $remaining -gt 0 ]; then
            echo "${YELLOW}  ... and $remaining more files${NC}"
        fi
        
        return 1
    else
        echo "${GREEN}No violations found for $message${NC}"
        return 0
    fi
}

# Run checks for each styling pattern
echo
echo "${BLUE}Checking for direct styling...${NC}"
echo

font_check=$(check_pattern "\.font(" "direct font usage")
color_check=$(check_pattern "\.foregroundColor(" "direct color usage")
padding_check=$(check_pattern "\.padding(" "direct padding usage")
corner_check=$(check_pattern "\.cornerRadius(" "direct corner radius usage")
shadow_check=$(check_pattern "\.shadow(" "direct shadow usage" "FOMOTheme.Shadow")

# Determine overall status
echo
if [[ $font_check -eq 0 && $color_check -eq 0 && $padding_check -eq 0 && $corner_check -eq 0 && $shadow_check -eq 0 ]]; then
    echo "${GREEN}✅ All files are using the design system correctly!${NC}"
    exit 0
else
    echo "${YELLOW}⚠️ Some files need to be updated to use the design system.${NC}"
    echo "${YELLOW}Run the migration script to fix issues:${NC}"
    echo "${BLUE}  ./scripts/migrate_theme.swift${NC}"
    # Exit with 0 to avoid failing the build
    exit 0
fi 