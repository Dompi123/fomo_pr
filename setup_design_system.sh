#!/bin/bash

# FOMO Design System Setup Script
# This script ensures the design system is properly set up for the preview environment

echo "Setting up FOMO Design System for preview environment..."

# Create necessary directories if they don't exist
mkdir -p FOMO_PR/Core/Design/Components

# Make sure design system files are included in the preview build
if grep -q "Design" build_preview.sh; then
  echo "Design system already included in build script"
else
  echo "Adding design system to build script..."
  sed -i '' 's|# Build the app|# Include Design System\ncp -R FOMO_PR/Core/Design temp_build_files/\n\n# Build the app|g' build_preview.sh
fi

# Check for required components
COMPONENTS=(
  "FOMO_PR/Core/Design/FOMOTheme.swift"
  "FOMO_PR/Core/Design/Components/FOMOText.swift"
  "FOMO_PR/Core/Design/Components/FOMOButton.swift"
  "FOMO_PR/Core/Design/Components/FOMOCard.swift"
  "FOMO_PR/Core/Design/Components/FOMOTag.swift"
  "FOMO_PR/Core/Design/Components/FOMOTextField.swift"
  "FOMO_PR/Core/Design/Components/FOMOToggle.swift"
  "FOMO_PR/Core/Design/Components/FOMOCheckbox.swift"
  "FOMO_PR/Core/Design/Components/FOMOPicker.swift"
  "FOMO_PR/Core/Design/ThemeShowcaseView.swift"
)

MISSING_FILES=0
for COMPONENT in "${COMPONENTS[@]}"; do
  if [ ! -f "$COMPONENT" ]; then
    echo "⚠️ Missing component: $COMPONENT"
    MISSING_FILES=1
  fi
done

if [ $MISSING_FILES -eq 1 ]; then
  echo "Some design system components are missing. Please make sure all components are correctly implemented."
  exit 1
fi

# Ensure bridge adapter is working
if grep -q "FOMOTheme adapter" FOMO_PR/Core/FOMOTheme.swift; then
  echo "Legacy adapter bridge is in place ✓"
else
  echo "⚠️ Legacy adapter missing. Please set up the bridge in FOMO_PR/Core/FOMOTheme.swift"
  exit 1
fi

# Update ContentView to show ThemeShowcaseView in preview mode
if grep -q "ThemeShowcaseView" ContentView.swift; then
  echo "ContentView already set up for design system showcase ✓"
else
  echo "Setting up ContentView to show ThemeShowcaseView in preview mode..."
  cp ContentView.swift ContentView.swift.bak
  cat > ContentView.swift << EOF
import SwiftUI

struct ContentView: View {
    var body: some View {
        ThemeShowcaseView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
EOF
fi

# Run the preview build to verify everything works
echo "Running preview build to verify design system setup..."
if ./build_preview.sh; then
  echo "✅ Design system successfully set up for preview environment!"
  echo "You can now see the design system showcase in the preview build."
else
  echo "❌ Preview build failed. Please check the error messages above."
  exit 1
fi 