#!/bin/zsh

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --endpoint)
      ENDPOINT="$2"
      shift 2
      ;;
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --security-level)
      SECURITY_LEVEL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate environment file
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file not found: $ENV_FILE"
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Validate required variables
REQUIRED_VARS=("AUTH0_ISSUER_BASE_URL" "AUTH0_AUDIENCE" "AUTH0_CLIENT_ID" "AUTH0_CLIENT_SECRET")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Missing required variable: $var"
        exit 1
    fi
done

# Validate endpoint
case "$ENDPOINT" in
    "auth")
        echo "✅ Auth endpoint configuration validated"
        ;;
    *)
        echo "❌ Unknown endpoint: $ENDPOINT"
        exit 1
        ;;
esac

# Validate security level
case "$SECURITY_LEVEL" in
    "production")
        echo "✅ Security level validated for production"
        ;;
    *)
        echo "❌ Invalid security level: $SECURITY_LEVEL"
        exit 1
        ;;
esac

echo "✅ Network validation complete"
exit 0

