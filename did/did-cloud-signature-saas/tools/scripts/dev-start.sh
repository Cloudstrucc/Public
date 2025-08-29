#!/usr/bin/env bash
set -Eeuo pipefail
echo "Starting development databases…"
docker compose up -d mongodb redis
echo "Waiting for databases to be ready…"
sleep 5
echo "Starting all services…"
yarn dev
