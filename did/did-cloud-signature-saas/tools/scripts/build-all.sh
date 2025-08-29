#!/usr/bin/env bash
set -Eeuo pipefail
echo "Building packages…"
yarn build:packages
echo "Building applications…"
yarn build:apps
echo "Build complete!"
