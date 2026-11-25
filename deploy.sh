#!/usr/bin/env bash
# Simple local deployment script for the Python app.
# Copies the application into a versioned release folder, points the
# "current" symlink at it, and runs a smoke test on the deployed copy.
set -euo pipefail

APP_NAME="jenkins_project"
DEPLOY_ROOT="${DEPLOY_DIR:-$HOME/deployments/$APP_NAME}"
RELEASE="${BUILD_NUMBER:-manual}-$(date +%Y%m%d%H%M%S)"
RELEASE_DIR="$DEPLOY_ROOT/releases/$RELEASE"

echo "Deploying $APP_NAME release $RELEASE to $DEPLOY_ROOT"
mkdir -p "$RELEASE_DIR"
cp app.py requirements.txt "$RELEASE_DIR/"

# Switch the "current" release atomically
ln -sfn "$RELEASE_DIR" "$DEPLOY_ROOT/current"

# Keep only the 5 most recent releases
ls -1dt "$DEPLOY_ROOT"/releases/* | tail -n +6 | xargs -r rm -rf

# Smoke test the deployed application
OUTPUT="$(python3 "$DEPLOY_ROOT/current/app.py")"
echo "Deployed app output: $OUTPUT"
if [ "$OUTPUT" != "Hello, World from Omar Tabsh!" ]; then
    echo "Smoke test FAILED" >&2
    exit 1
fi
echo "Deployment successful: $DEPLOY_ROOT/current -> $RELEASE_DIR"
