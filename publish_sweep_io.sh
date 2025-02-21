#!/bin/bash

# Exit on errors
set -e

set -x

echo "Cleaning files"
rm -rf temp-package xyflow-monorepo-0.0.0.tgz

# Variables
REGISTRY="https://npm.pkg.github.com"  # Change if using a different registry
ACCESS="restricted"  # Use "public" if publishing a public package

# Step 1: Pack the package
echo "Packing the package..."
TARBALL=$(pnpm pack --silent)
echo "Created tarball: $TARBALL"

# Step 2: Extract tarball
mkdir -p temp-package
tar -xzf "$TARBALL" -C temp-package

cd temp-package/package

# Step 3: Replace package names:
find . -type f -name "*.js" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/react/@sweep-io\/react/g'
find . -type f -name "*.ts" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/react/@sweep-io\/react/g'
find . -type f -name "*.tsx" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/react/@sweep-io\/react/g'
find . -type f -name "package.json" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/react/@sweep-io\/react/g'


find . -type f -name "*.js" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/system/@sweep-io\/system/g'
find . -type f -name "*.ts" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/system/@sweep-io\/system/g'
find . -type f -name "*.tsx" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/system/@sweep-io\/system/g'
find . -type f -name "package.json" -print0 | xargs -0 sed -i '' -e 's/@xyflow\/system/@sweep-io\/system/g'

# Replace the URI
find . -type f -name "package.json" -print0 | xargs -0 sed -i '' -e 's/xyflow\/xyflow.git/sweep-io\/xyflow.git/g'

# Step 4: Authenticate (optional)
# echo "//npm.pkg.github.com/:_authToken=${NPM_AUTH_TOKEN}" > ~/.npmrc

pnpm install

cd packages/system
pnpm build
pnpm publish  --registry="$REGISTRY" --access="$ACCESS" --no-git-checks

cd ../../
cd packages/react
pnpm build
pnpm publish  --registry="$REGISTRY" --access="$ACCESS" --no-git-checks

# Cleanup
cd ../../../..
rm -rf temp-package "$TARBALL"

echo "✅ Successfully published"

