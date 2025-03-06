#!/bin/bash

# FOMO Design System Compliance Check for CI/CD
# This script runs design system compliance checks and can be integrated into CI pipelines.
# It will fail if direct styling usage exceeds the specified threshold.

set -e

# Configuration
PROJECT_DIR=${1:-"../FOMO_PR"}
THRESHOLD=${2:-10}  # Maximum allowed percentage of direct styling
EXCLUSIONS="Core/Design/ Core/Utils/ Core/Network/ Core/Storage/ Core/Analytics/ Generated/ Tests/"

echo "🎨 FOMO Design System Compliance Check"
echo "======================================="
echo "Project directory: $PROJECT_DIR"
echo "Direct styling threshold: $THRESHOLD%"
echo

# Count total Swift files
total_swift_files=$(find "$PROJECT_DIR" -name "*.swift" | grep -v -E "$EXCLUSIONS" | wc -l | tr -d ' ')
echo "Total Swift files to check: $total_swift_files"

# Function to count occurrences of a pattern
function count_pattern() {
    pattern=$1
    name=$2
    exclusion=${3:-"FOMOTheme"}
    
    count=$(grep -r "$pattern" --include="*.swift" "$PROJECT_DIR" | grep -v -E "$EXCLUSIONS" | grep -v "$exclusion" | wc -l | tr -d ' ')
    echo "Direct $name usage: $count instances"
    return $count
}

# Check for direct styling
echo
echo "Running compliance checks..."
echo

# Font usage
font_count=$(count_pattern "\.font(" "font")
# Color usage
color_count=$(count_pattern "\.foregroundColor(" "color")
# Padding usage
padding_count=$(count_pattern "\.padding(" "padding")
# Corner radius usage
corner_count=$(count_pattern "\.cornerRadius(" "corner radius")
# Shadow usage
shadow_count=$(count_pattern "\.shadow(" "shadow" "FOMOTheme.Shadow")

# Calculate total direct styling
total_direct_styling=$((font_count + color_count + padding_count + corner_count + shadow_count))
echo
echo "Total direct styling instances: $total_direct_styling"

# Calculate percentage (assuming each file has ~5 styling instances on average)
estimated_total_styling=$((total_swift_files * 5))
percentage=$((total_direct_styling * 100 / estimated_total_styling))

echo "Estimated compliance: $((100 - percentage))%"
echo

# Show examples of violations
echo "Examples of direct styling:"
echo "-------------------------"
echo "Fonts:"
grep -r "\.font(" --include="*.swift" "$PROJECT_DIR" | grep -v -E "$EXCLUSIONS" | grep -v "FOMOTheme" | head -3

echo
echo "Colors:"
grep -r "\.foregroundColor(" --include="*.swift" "$PROJECT_DIR" | grep -v -E "$EXCLUSIONS" | grep -v "FOMOTheme" | head -3

echo
echo "Padding:"
grep -r "\.padding(" --include="*.swift" "$PROJECT_DIR" | grep -v -E "$EXCLUSIONS" | grep -v "FOMOTheme" | head -3

# Determine pass/fail based on threshold
if [ $percentage -gt $THRESHOLD ]; then
    echo
    echo "❌ FAILED: Direct styling usage ($percentage%) exceeds threshold ($THRESHOLD%)"
    echo "Run ./scripts/migrate_theme.swift to fix styling issues"
    exit 1
else
    echo
    echo "✅ PASSED: Direct styling usage ($percentage%) is below threshold ($THRESHOLD%)"
    exit 0
fi 