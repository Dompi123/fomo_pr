#!/bin/bash

# Design System Usage Check
# This script checks for direct styling in Swift files that should be using the FOMOTheme design system.

echo "FOMO Design System Usage Check"
echo "=============================="
echo

# Project directory path
PROJECT_DIR="../FOMO_PR"

# Count total Swift files
total_files=$(find "$PROJECT_DIR" -name "*.swift" | grep -v "/Core/Design/" | wc -l)
echo "Total Swift files (excluding Core/Design): $total_files"
echo

# Check for direct font usage
echo "Checking for direct font usage..."
direct_font_count=$(grep -r "\.font(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | wc -l)
echo "Files with direct font usage: $direct_font_count"

# Check for direct color usage
echo "Checking for direct color usage..."
direct_color_count=$(grep -r "\.foregroundColor(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | wc -l)
echo "Files with direct color usage: $direct_color_count"

# Check for direct padding usage
echo "Checking for direct padding usage..."
direct_padding_count=$(grep -r "\.padding(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | wc -l)
echo "Files with direct padding usage: $direct_padding_count"

# Check for direct corner radius usage
echo "Checking for direct corner radius usage..."
direct_corner_radius_count=$(grep -r "\.cornerRadius(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | wc -l)
echo "Files with direct corner radius usage: $direct_corner_radius_count"

echo
echo "Files using direct styling:"
echo "=========================="

# Show examples of files with direct styling
echo "Font usage examples:"
grep -r "\.font(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | head -5

echo
echo "Color usage examples:"
grep -r "\.foregroundColor(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | head -5

echo
echo "Padding usage examples:"
grep -r "\.padding(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | head -5

echo
echo "Corner radius usage examples:"
grep -r "\.cornerRadius(" --include="*.swift" "$PROJECT_DIR" | grep -v "FOMOTheme" | grep -v "/Core/Design/" | head -5

echo
echo "Summary:"
echo "========"
direct_styling_total=$((direct_font_count + direct_color_count + direct_padding_count + direct_corner_radius_count))
echo "Total instances of direct styling: $direct_styling_total"

# Calculate compliance percentage
if [ $direct_styling_total -gt 0 ]; then
    estimated_total_styling=$((direct_styling_total * 100 / (100 - $(($direct_styling_total * 100 / (total_files * 10))))))
    compliance_percentage=$((100 - $(($direct_styling_total * 100 / estimated_total_styling))))
    echo "Estimated design system compliance: $compliance_percentage%"
    
    if [ $compliance_percentage -lt 50 ]; then
        echo "Status: ❌ Significant work needed"
    elif [ $compliance_percentage -lt 80 ]; then
        echo "Status: ⚠️ Making progress"
    else
        echo "Status: ✅ Good compliance"
    fi
else
    echo "Estimated design system compliance: 100%"
    echo "Status: ✅ Perfect compliance"
fi 