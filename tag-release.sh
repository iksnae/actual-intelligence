#!/bin/bash
# Script to create and push a new release tag

# Check if a version tag was provided
if [ $# -eq 0 ]; then
    echo "Error: No version tag provided"
    echo "Usage: ./tag-release.sh v1.0.0"
    exit 1
fi

VERSION=$1

# Validate version tag format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version tag must be in format v1.0.0"
    exit 1
fi

# Confirm with user
echo "Creating release tag: $VERSION"
read -p "Are you sure you want to create and push this tag? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 1
fi

# Create and push the tag
echo "Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

echo "Pushing tag to remote..."
git push origin "$VERSION"

echo "Release tag $VERSION created and pushed!"
echo "The GitHub workflow will automatically build and release the book." 