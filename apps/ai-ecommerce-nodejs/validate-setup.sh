#!/bin/bash
# Validation script to check if all files are created correctly

echo "🔍 Validating AI E-commerce Platform setup..."

REQUIRED_FILES=(
    "docker-compose.yml"
    "Makefile"
    ".env"
    "README.md"
    "QUICK-START.md"
    "express-api/package.json"
    "express-api/Dockerfile"
    "express-api/prisma/schema.prisma"
    "nextjs-frontend/package.json"
    "nextjs-frontend/Dockerfile"
    "nextjs-frontend/next.config.js"
    "python-agent/main.py"
    "python-agent/Dockerfile"
    "python-agent/requirements.txt"
    "monitoring/prometheus/prometheus.yml"
    "scripts/health-check.sh"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✅ All required files are present!"
    echo "✅ Setup validation passed!"
    return 0
else
    echo "❌ Missing files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
    return 1
fi
