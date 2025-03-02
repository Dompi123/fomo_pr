#!/bin/bash

# This script helps set up the Xcode project settings
# It will guide you through the manual steps needed

# Set colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${GREEN}===== Xcode Project Settings Helper =====${NC}"
echo -e "${YELLOW}This script will guide you through setting up your Xcode project settings.${NC}"
echo ""

echo -e "${BLUE}Step 1: Open your Xcode project${NC}"
echo -e "${YELLOW}1. Open Xcode${NC}"
echo -e "${YELLOW}2. Open your FOMO_PR project${NC}"
echo ""
read -p "Press Enter when you have opened your project in Xcode..."

echo -e "${BLUE}Step 2: Add the new files to your project${NC}"
echo -e "${YELLOW}1. In Xcode, right-click on your FOMO_PR group in the Project Navigator${NC}"
echo -e "${YELLOW}2. Select 'Add Files to \"FOMO_PR\"...'${NC}"
echo -e "${YELLOW}3. Navigate to the following files:${NC}"
echo -e "${YELLOW}   - FOMO_PR/SecurityTypes.swift${NC}"
echo -e "${YELLOW}   - FOMO_PR/FOMO_PR.modulemap${NC}"
echo -e "${YELLOW}   - FOMO_PR/PaymentManager.swift${NC}"
echo -e "${YELLOW}   - FOMO_PR/XcodeTypeHelper.swift${NC}"
echo -e "${YELLOW}   - FOMO_PR/FOMO_PR-Bridging-Header.h${NC}"
echo -e "${YELLOW}4. Make sure 'Copy items if needed' is checked${NC}"
echo -e "${YELLOW}5. Click 'Add'${NC}"
echo ""
echo -e "${RED}If 'Add Files' doesn't work, try this alternative:${NC}"
echo -e "${YELLOW}1. In Finder, navigate to /Users/dom.khr/fomopr/FOMO_PR/${NC}"
echo -e "${YELLOW}2. Drag and drop the files directly into your Xcode project navigator${NC}"
echo ""
read -p "Press Enter when you have added the files to your project..."

echo -e "${BLUE}Step 3: Update your Xcode project settings${NC}"
echo -e "${YELLOW}1. Select your project in the Project Navigator${NC}"
echo -e "${YELLOW}2. Select the 'FOMO_PR' target${NC}"
echo -e "${YELLOW}3. Go to the 'Build Settings' tab${NC}"
echo -e "${YELLOW}4. Search for 'bridging header'${NC}"
echo -e "${YELLOW}5. Set 'Objective-C Bridging Header' to 'FOMO_PR/FOMO_PR-Bridging-Header.h'${NC}"
echo -e "${YELLOW}6. Search for 'module map'${NC}"
echo -e "${YELLOW}7. Set 'Module Map File' to 'FOMO_PR/FOMO_PR.modulemap'${NC}"
echo -e "${YELLOW}8. Search for 'module'${NC}"
echo -e "${YELLOW}9. Make sure 'Defines Module' is set to 'Yes'${NC}"
echo -e "${YELLOW}10. Make sure 'Product Module Name' is set to 'FOMO_PR'${NC}"
echo ""
read -p "Press Enter when you have updated your project settings..."

echo -e "${BLUE}Step 4: Remove conflicting files from your project${NC}"
echo -e "${YELLOW}In the Project Navigator, find and remove these files (choose 'Remove Reference', NOT 'Move to Trash'):${NC}"
echo -e "${YELLOW}- Core/Payment/TokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/Tokenization/TokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/Tokenization/LiveTokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/Tokenization/MockTokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/LiveTokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/MockTokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Network/TokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/PaymentServiceProtocol.swift${NC}"
echo -e "${YELLOW}- Core/Payment/PaymentState.swift${NC}"
echo -e "${YELLOW}- Core/Payment/PaymentManager.swift${NC}"
echo ""
read -p "Press Enter when you have removed the conflicting files..."

echo -e "${BLUE}Step 5: Clean and rebuild${NC}"
echo -e "${YELLOW}1. In Xcode, go to Product > Clean Build Folder${NC}"
echo -e "${YELLOW}2. Close Xcode completely${NC}"
echo -e "${YELLOW}3. Reopen Xcode and your project${NC}"
echo -e "${YELLOW}4. Build the project (Command+B)${NC}"
echo ""
echo -e "${GREEN}That's it! Your project should now build successfully.${NC}"
echo -e "${YELLOW}If you still have issues, please refer to the FINAL_FIX_GUIDE.md file.${NC}"
