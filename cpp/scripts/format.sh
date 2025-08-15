#!/bin/bash

# Format all C++ source files in the project
# Excludes external dependencies and build directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🎨 Formatting C++ files in: $PROJECT_DIR"

# Find and format all C++ files, excluding external dependencies
find "$PROJECT_DIR" \
    \( -path "$PROJECT_DIR/_deps" -o -path "$PROJECT_DIR/build" \) -prune -o \
    \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -type f -print | \
while IFS= read -r file; do
    echo "📝 Formatting: $(realpath --relative-to="$PROJECT_DIR" "$file")"
    clang-format -i "$file"
done

echo "✅ All C++ files formatted successfully!"
