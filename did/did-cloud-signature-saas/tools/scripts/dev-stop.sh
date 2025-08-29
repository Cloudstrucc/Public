#!/usr/bin/env bash
set -Eeuo pipefail
echo "Stopping development databases…"
docker compose down
echo "Development environment stopped."
