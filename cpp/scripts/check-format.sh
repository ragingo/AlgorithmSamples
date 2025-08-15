#!/bin/bash

# Check if all C++ source files are properly formatted
# Excludes external dependencies and build directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔍 Checking C++ file formatting in: $PROJECT_DIR"

# Find and check all C++ files, excluding external dependencies
find "$PROJECT_DIR" \
    \( -path "$PROJECT_DIR/_deps" -o -path "$PROJECT_DIR/build" \) -prune -o \
    \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -type f -print | \
while IFS= read -r file; do
    if ! diff -q "$file" <(clang-format "$file") > /dev/null 2>&1; then
        echo "❌ Needs formatting: $(realpath --relative-to="$PROJECT_DIR" "$file")"
        exit 1
    fi
done

if [ $? -eq 0 ]; then
    echo "✅ All files are properly formatted!"
else
    echo "❌ Some files need formatting. Run format.sh to fix them."
    exit 1
fi
