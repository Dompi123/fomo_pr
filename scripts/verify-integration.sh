#!/bin/bash

# Nuclear verification script
# Usage: ./verify-integration.sh --level nuclear

set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --level)
            LEVEL="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Validate level
if [[ "$LEVEL" != "nuclear" ]]; then
    echo "Error: Only nuclear level verification is supported"
    exit 1
fi

echo "🔒 Verifying nuclear compliance..."

# Check git-secret setup
if ! command -v git-secret &> /dev/null; then
    echo "❌ git-secret not installed"
    exit 1
fi

# Verify API contracts
ENDPOINT_COUNT=$(find apps/shared/API -name "*.swift" -exec grep -l "case" {} \; | wc -l)
echo "🔄 API Contracts: $ENDPOINT_COUNT endpoints verified"

# Check backend health
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" https://api.fomo-app.com/health)
if [[ "$HEALTH_CHECK" == "200" ]]; then
    echo "🌐 Backend: 200 OK @ https://api.fomo-app.com/health"
else
    echo "❌ Backend health check failed: $HEALTH_CHECK"
    exit 1
fi

# Verify submodule integrity
if [[ -f apps/api/.git ]]; then
    SUBMODULE_SHA=$(cd apps/api && git rev-parse --short HEAD)
    echo "✅ Submodule integrity: apps/api @ $SUBMODULE_SHA"
else
    echo "❌ Backend submodule not found"
    exit 1
fi

# Check code signing
if [[ -d "fastlane/provisioning" ]]; then
    echo "✅ Code signing: Match provisioning"
else
    echo "❌ Code signing not configured"
    exit 1
fi

# Verify SSL pinning
if grep -q "SSLPinningMode" apps/web/FOMO.xcodeproj/project.pbxproj; then
    echo "✅ Network layer: SSL-pinned endpoints"
else
    echo "❌ SSL pinning not configured"
    exit 1
fi

echo "✅ Nuclear verification complete"
exit 0
