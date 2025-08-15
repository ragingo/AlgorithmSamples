#!/bin/bash

# 既存ファイルの文字エンコードと改行コードを一括変換
# C++ファイル: UTF-8 with BOM + LF
# シェルスクリプト: UTF-8 without BOM + LF

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔄 Converting file encodings and line endings..."
echo "📁 Project directory: $PROJECT_DIR"

# C++ファイルをUTF-8 with BOM + LFに変換
echo ""
echo "📝 Converting C++ files to UTF-8 with BOM + LF..."
find "$PROJECT_DIR" \
    \( -path "$PROJECT_DIR/_deps" -o -path "$PROJECT_DIR/build" \) -prune -o \
    \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -type f -print | \
while IFS= read -r file; do
    relative_path=$(realpath --relative-to="$PROJECT_DIR" "$file")
    echo "  🔧 $relative_path"

    # 文字エンコードをUTF-8 with BOMに変換
    # UTF-8 BOMを追加 (既にある場合は重複を避ける)
    first_bytes=$(head -c 3 "$file" | od -An -tx1 | tr -d ' ')
    if [ "$first_bytes" != "efbbbf" ]; then
        # BOMを追加 (より確実な方法)
        (printf '\xef\xbb\xbf'; cat "$file") > "${file}.new"
        mv "${file}.new" "$file"
        echo "    ✅ Added BOM"
    else
        echo "    ℹ️  BOM already present"
    fi

    # 改行コードをLFに統一
    if command -v dos2unix >/dev/null 2>&1; then
        dos2unix "$file" 2>/dev/null || true
    else
        # dos2unixがない場合はsedで代替
        sed -i 's/\r$//' "$file" 2>/dev/null || true
    fi
done

# シェルスクリプトをUTF-8 without BOM + LFに変換
echo ""
echo "🐚 Converting shell scripts to UTF-8 without BOM + LF..."
find "$PROJECT_DIR" \
    \( -path "$PROJECT_DIR/_deps" -o -path "$PROJECT_DIR/build" \) -prune -o \
    \( -name "*.sh" -o -name "*.bash" \) -type f -print | \
while IFS= read -r file; do
    relative_path=$(realpath --relative-to="$PROJECT_DIR" "$file")
    echo "  🔧 $relative_path"

    # BOMを削除 (もしあれば)
    first_bytes=$(head -c 3 "$file" | od -An -tx1 | tr -d ' ')
    if [ "$first_bytes" = "efbbbf" ]; then
        # BOMを削除
        tail -c +4 "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
        echo "    ✅ Removed BOM"
    else
        echo "    ℹ️  No BOM present"
    fi

    # 改行コードをLFに統一
    if command -v dos2unix >/dev/null 2>&1; then
        dos2unix "$file" 2>/dev/null || true
    else
        sed -i 's/\r$//' "$file" 2>/dev/null || true
    fi

    # 実行権限を確保
    chmod +x "$file"
done

# JSONファイルをUTF-8 without BOM + LFに変換
echo ""
echo "📄 Converting JSON files to UTF-8 without BOM + LF..."
find "$PROJECT_DIR/.vscode" -name "*.json" -type f 2>/dev/null | \
while IFS= read -r file; do
    relative_path=$(realpath --relative-to="$PROJECT_DIR" "$file")
    echo "  🔧 $relative_path"

    # BOMを削除 (もしあれば)
    first_bytes=$(head -c 3 "$file" | od -An -tx1 | tr -d ' ')
    if [ "$first_bytes" = "efbbbf" ]; then
        # BOMを削除
        tail -c +4 "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
        echo "    ✅ Removed BOM"
    else
        echo "    ℹ️  No BOM present"
    fi

    # 改行コードをLFに統一
    if command -v dos2unix >/dev/null 2>&1; then
        dos2unix "$file" 2>/dev/null || true
    else
        sed -i 's/\r$//' "$file" 2>/dev/null || true
    fi
done

echo ""
echo "✅ File encoding and line ending conversion completed!"
echo "📋 Summary:"
echo "   • C++ files: UTF-8 with BOM + LF"
echo "   • Shell scripts: UTF-8 without BOM + LF"
echo "   • JSON files: UTF-8 without BOM + LF"
