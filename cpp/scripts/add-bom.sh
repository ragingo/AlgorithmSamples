#!/bin/bash

# 確実にBOMを追加するシンプルなスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔄 Adding BOM to C++ files..."
echo "📁 Project directory: $PROJECT_DIR"

# C++ファイルを動的に検索してBOMを追加
find "$PROJECT_DIR" \
    \( -path "$PROJECT_DIR/_deps" -o -path "$PROJECT_DIR/build" \) -prune -o \
    \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -type f -print | \
while IFS= read -r file; do
    relative_path=$(realpath --relative-to="$PROJECT_DIR" "$file")
    echo "Processing: $relative_path"

    # BOM確認
    first_bytes=$(head -c 3 "$file" | od -An -tx1 | tr -d ' ')
    echo "  Current first bytes: $first_bytes"

    if [ "$first_bytes" != "efbbbf" ]; then
        echo "  Adding BOM..."
        (printf '\xef\xbb\xbf'; cat "$file") > "${file}.bom"
        mv "${file}.bom" "$file"
        echo "  ✅ BOM added"
    else
        echo "  ℹ️  BOM already present"
    fi

    # 確認
    new_bytes=$(head -c 6 "$file" | od -tx1)
    echo "  After: $new_bytes"
    echo ""
done

echo "✅ BOM addition completed!"
