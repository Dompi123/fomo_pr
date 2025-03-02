#!/bin/bash

echo "Fixing project file to include APIClient.swift..."

PROJECT_FILE="FOMO_PR.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_FILE" ]; then
    # Backup the file
    cp "$PROJECT_FILE" "${PROJECT_FILE}.critical.backup"
    
    # Generate a unique file reference ID (similar to what Xcode would generate)
    FILE_REF_ID="ABCDEF0987654321"
    BUILD_FILE_ID="ABCDEF1234567890"
    
    # Find the PBXBuildFile section and add our file
    awk '
    /\/\* Begin PBXBuildFile section \*\// {
        print $0;
        print "\t\t'"$BUILD_FILE_ID"' /* APIClient.swift in Sources */ = {isa = PBXBuildFile; fileRef = '"$FILE_REF_ID"' /* APIClient.swift */; };";
        next;
    }
    { print }
    ' "$PROJECT_FILE" > "${PROJECT_FILE}.temp1"
    
    # Find the PBXFileReference section and add our file
    awk '
    /\/\* Begin PBXFileReference section \*\// {
        print $0;
        print "\t\t'"$FILE_REF_ID"' /* APIClient.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = APIClient.swift; path = FOMO_PR/Networking/APIClient.swift; sourceTree = SOURCE_ROOT; };";
        next;
    }
    { print }
    ' "${PROJECT_FILE}.temp1" > "${PROJECT_FILE}.temp2"
    
    # Find the PBXGroup section for the FOMO_PR group and add our file
    awk '
    /\/\* FOMO_PR \*\/ = \{/ {
        inGroup = 1;
    }
    inGroup && /children = \(/ {
        print $0;
        print "\t\t\t\t'"$FILE_REF_ID"' /* APIClient.swift */,";
        inGroup = 0;
        next;
    }
    { print }
    ' "${PROJECT_FILE}.temp2" > "${PROJECT_FILE}.temp3"
    
    # Find the PBXSourcesBuildPhase section and add our file
    awk '
    /\/\* Sources \*\/ = \{/ {
        inSources = 1;
    }
    inSources && /files = \(/ {
        print $0;
        print "\t\t\t\t'"$BUILD_FILE_ID"' /* APIClient.swift in Sources */,";
        inSources = 0;
        next;
    }
    { print }
    ' "${PROJECT_FILE}.temp3" > "${PROJECT_FILE}.temp4"
    
    # Replace the original file
    mv "${PROJECT_FILE}.temp4" "$PROJECT_FILE"
    
    # Clean up temporary files
    rm -f "${PROJECT_FILE}.temp1" "${PROJECT_FILE}.temp2" "${PROJECT_FILE}.temp3"
    
    echo "Project file updated to include APIClient.swift."
else
    echo "❌ Project file not found at $PROJECT_FILE"
fi 