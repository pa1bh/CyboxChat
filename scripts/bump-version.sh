#!/bin/bash
# Bump version script for CyboxChat
# Usage: ./scripts/bump-version.sh [major|minor|patch|build]

set -e
cd "$(dirname "$0")/.."

# Get current version from project
CURRENT_VERSION=$(grep -A1 'MARKETING_VERSION' CyboxChat.xcodeproj/project.pbxproj | grep -o '[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?' | head -1)
CURRENT_BUILD=$(grep -A1 'CURRENT_PROJECT_VERSION' CyboxChat.xcodeproj/project.pbxproj | grep -o '[0-9]\+' | head -1)

# Parse version parts
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
PATCH=${PATCH:-0}

echo "Current version: $MAJOR.$MINOR.$PATCH (build $CURRENT_BUILD)"

case "${1:-build}" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    build)
        CURRENT_BUILD=$((CURRENT_BUILD + 1))
        ;;
    *)
        echo "Usage: $0 [major|minor|patch|build]"
        echo "  major: 1.0.0 -> 2.0.0"
        echo "  minor: 1.0.0 -> 1.1.0"
        echo "  patch: 1.0.0 -> 1.0.1"
        echo "  build: increment build number only (default)"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update project.pbxproj
if [[ "$1" != "build" && -n "$1" ]]; then
    sed -i '' "s/MARKETING_VERSION = [0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?;/MARKETING_VERSION = $NEW_VERSION;/g" CyboxChat.xcodeproj/project.pbxproj
    echo "Version bumped to: $NEW_VERSION"
fi

sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]\+;/CURRENT_PROJECT_VERSION = $CURRENT_BUILD;/g" CyboxChat.xcodeproj/project.pbxproj

echo "New version: $NEW_VERSION (build $CURRENT_BUILD)"
