#!/bin/bash

echo "Setting up enhanced crash reporting for FOMO_PR app..."

# Create a directory for crash logs if it doesn't exist
mkdir -p ~/Library/Logs/CrashReporter/FOMO_PR

# Set environment variables for more detailed crash logs
export NSZombieEnabled=YES
export NSDebugEnabled=YES
export NSAutoreleaseFreedObjectCheckEnabled=YES
export MallocStackLogging=YES
export MallocScribble=YES
export MallocGuardEdges=YES
export OBJC_DEBUG_MISSING_POOLS=YES
export OBJC_DEBUG_UNRETAINED_OBJC=YES

# Set up environment for more detailed logging
export OS_ACTIVITY_MODE=debug
export CFNETWORK_DIAGNOSTICS=3

echo "Environment variables set for enhanced debugging"
echo "Please run the app from Xcode now with these settings"
echo "After the crash, check the following locations for logs:"
echo "- ~/Library/Logs/CrashReporter/"
echo "- ~/Library/Logs/DiagnosticReports/"
echo "- Console.app (filter by 'FOMO_PR')"

# Instructions for running the app
echo ""
echo "To run the app with these settings, use the following steps:"
echo "1. In Xcode, select Product > Scheme > Edit Scheme"
echo "2. Select the 'Run' action and go to the 'Arguments' tab"
echo "3. Add the following environment variables:"
echo "   - NSZombieEnabled = YES"
echo "   - OS_ACTIVITY_MODE = debug"
echo "4. Run the app and observe the console output"
echo ""
echo "This script has set these variables in the current shell session."
echo "You can also run the app directly from the command line with:"
echo "xcrun simctl launch --console-pty booted com.fomo.app" 