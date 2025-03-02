#!/bin/bash

# Script to help remove conflicting files from the Xcode project
# This script will guide you through removing files that conflict with our new implementation

# Set colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${GREEN}===== Remove Conflicting Files Helper =====${NC}"
echo -e "${YELLOW}This script will guide you through removing conflicting files from your Xcode project.${NC}"
echo ""

echo -e "${BLUE}Files to remove from your project:${NC}"
echo -e "${YELLOW}In the Project Navigator, find and remove these files (choose 'Remove Reference', NOT 'Move to Trash'):${NC}"
echo -e "${YELLOW}- Core/Payment/TokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/Tokenization/TokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/Tokenization/LiveTokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/Tokenization/MockTokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Network/TokenizationService.swift${NC}"
echo -e "${YELLOW}- Core/Payment/PaymentManager.swift${NC}"
echo -e "${YELLOW}- FOMOTypes.swift (if it contains TokenizationService definitions)${NC}"
echo ""

echo -e "${BLUE}Steps to remove files:${NC}"
echo -e "${YELLOW}1. In Xcode, locate each file in the Project Navigator${NC}"
echo -e "${YELLOW}2. Right-click on the file${NC}"
echo -e "${YELLOW}3. Select 'Delete'${NC}"
echo -e "${YELLOW}4. In the confirmation dialog, choose 'Remove Reference' (NOT 'Move to Trash')${NC}"
echo ""

echo -e "${BLUE}After removing files:${NC}"
echo -e "${YELLOW}1. Clean your build folder (Product > Clean Build Folder)${NC}"
echo -e "${YELLOW}2. Close Xcode completely${NC}"
echo -e "${YELLOW}3. Reopen Xcode and your project${NC}"
echo -e "${YELLOW}4. Build the project (Command+B)${NC}"
echo ""

echo -e "${GREEN}This should resolve the conflicts with multiple definitions of TokenizationService and Security namespace.${NC}"
echo -e "${YELLOW}If you still have issues, please check for other files that might be defining the same types.${NC}"
echo ""

# Make the script executable
chmod +x FOMO_PR/remove_conflicting_files.sh 