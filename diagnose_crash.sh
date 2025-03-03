#!/bin/bash

echo "=== Starting FOMO_PR Crash Diagnosis ==="
echo "This script will run the app and capture logs to help diagnose crashes"

# Create a log directory if it doesn't exist
mkdir -p crash_logs

# Get current timestamp for log files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="crash_logs/fomo_pr_log_${TIMESTAMP}.txt"

echo "Logs will be saved to: $LOG_FILE"

# Clean build directory
echo "Cleaning build directory..."
xcodebuild clean -project FOMO_PR.xcodeproj -scheme FOMO_PR

# Set environment variables for verbose logging
export OS_ACTIVITY_MODE=debug
export CFNETWORK_DIAGNOSTICS=3

# Build and run with logging
echo "Building and running app with enhanced logging..."
echo "=== Build and Run Log ===" > "$LOG_FILE"
echo "Started at: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Run the app with logging redirected to our log file
# Note: This will run in the simulator - adjust the destination if needed
xcodebuild build -project FOMO_PR.xcodeproj -scheme FOMO_PR -destination 'platform=iOS Simulator,name=iPhone 15' -configuration Debug | tee -a "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "=== System Log Entries ===" >> "$LOG_FILE"

# Capture simulator logs
xcrun simctl spawn booted log show --predicate 'subsystem contains "com.fomo"' --style compact --last 1h | tee -a "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "=== Crash Report Summary ===" >> "$LOG_FILE"
xcrun simctl spawn booted log show --predicate 'eventMessage contains "crash"' --style compact --last 1h | tee -a "$LOG_FILE"

echo "Diagnosis complete. Check $LOG_FILE for details."
echo "If the app crashed, look for KeychainManager and ProfileViewModel log entries to identify the issue."
echo "=== Diagnosis Complete ===" 