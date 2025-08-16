#!/bin/bash

# Unified clang-tidy runner script for AlgorithmSamples C++ project
# Usage:
#   bash lint.sh        # Local analysis (direct output)
#   bash lint.sh --pr   # PR analysis (generates Markdown report)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_DIR="$(dirname "$SCRIPT_DIR")"

# Parse arguments
PR_MODE=false
if [ "$1" = "--pr" ]; then
    PR_MODE=true
    echo "Generating clang-tidy report for PR..."
else
    echo "Running clang-tidy on C++ code..."
fi

# Check if clang-tidy is available
if ! command -v clang-tidy &> /dev/null; then
    echo "Error: clang-tidy is not installed or not in PATH"
    echo "Please install clang-tidy first:"
    echo "  - On Windows: Install LLVM/Clang tools"
    echo "  - On Ubuntu: sudo apt install clang-tidy"
    echo "  - On macOS: brew install llvm"
    exit 1
fi

cd "$CPP_DIR" || exit 1

# Setup platform-specific arguments
EXTRA_ARGS="--extra-arg=-std=c++23 --extra-arg=-I."
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OS" == "Windows_NT" ]]; then
    echo "Detected Windows environment"
    EXTRA_ARGS="$EXTRA_ARGS --extra-arg=-target --extra-arg=x86_64-pc-windows-msvc"
    EXTRA_ARGS="$EXTRA_ARGS --extra-arg=-fms-compatibility-version=19"
    EXTRA_ARGS="$EXTRA_ARGS --extra-arg=-Wno-unknown-pragmas --extra-arg=-fno-caret-diagnostics"
    WIN_ARGS="--extra-arg=-target --extra-arg=x86_64-pc-windows-msvc --extra-arg=-fms-compatibility-version=19 --extra-arg=-Wno-unknown-pragmas"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux environment"
    WIN_ARGS=""
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS environment"
    WIN_ARGS=""
fi

# Common error filter patterns (simplified)
FILTER_PATTERN="Could not auto-detect|No compilation database|fixed-compilation-database|json-compilation-database|Error reading|Error while processing|no such file|no input files|unable to handle|file not found|fatal error|clang-diagnostic-error"

# Common function to run clang-tidy with filtering
run_clang_tidy() {
    local file="$1"
    clang-tidy "$file" --extra-arg=-std=c++23 --extra-arg=-I. $WIN_ARGS --format-style=file 2>&1 | \
        grep -vE "$FILTER_PATTERN" | \
        grep -E "^.*\.(cpp|hpp|h):[0-9]+:[0-9]+: warning:"
}

# Function to get rule description
get_rule_description() {
    case "$1" in
        "readability-identifier-length") echo "変数名が短すぎます (3文字以上推奨)" ;;
        "modernize-use-auto") echo "auto キーワードの使用を推奨" ;;
        "performance-for-range-copy") echo "range-forループでコピーを避けることを推奨" ;;
        "bugprone-unused-raii") echo "RAII オブジェクトが未使用です" ;;
        "cppcoreguidelines-init-variables") echo "変数の初期化が必要です" ;;
        "modernize-use-nullptr") echo "nullptr の使用を推奨" ;;
        "performance-unnecessary-copy-initialization") echo "不要なコピー初期化を避けることを推奨" ;;
        *) echo "コード品質の改善が必要です" ;;
    esac
}

# Function to generate markdown report
generate_markdown_report() {
    local warning_count="$1"
    local warnings_file="$2"

    cat > pr_lint_summary.md << EOF
## 🔍 Clang-tidy Analysis Results

EOF

    if [ "$warning_count" -gt 0 ]; then
        cat >> pr_lint_summary.md << EOF
Found **$warning_count** code style/quality issues:

### 📊 Most Common Issues:

| ルール | 件数 | 説明 |
|--------|------|------|
EOF

        # Generate rule statistics
        grep "LINT_WARNING:" "$warnings_file" | sed 's/LINT_WARNING: //' | \
            sed -E 's/.*\[([^]]*)\]$/\1/' | sort | uniq -c | sort -nr | head -5 | \
            while read count rule; do
                description=$(get_rule_description "$rule")
                echo "| \`$rule\` | $count | $description |" >> pr_lint_summary.md
            done

        cat >> pr_lint_summary.md << EOF

### 📝 Detailed Issues:

| ファイル | 行 | 問題の説明 | ルール |
|----------|----|-----------|---------|
EOF

        # Generate detailed issues table
        grep "LINT_WARNING:" "$warnings_file" | sed 's/LINT_WARNING: //' | \
            sed -E 's|^.*[/\\]([^/\\]+):([0-9]+):[0-9]+: warning: (.*) \[([^]]*)\]$|\1\t\2\t\3\t\4|' | \
            sort -u | head -10 | \
            while IFS=$'\t' read -r file line message rule; do
                echo "| \`$file\` | $line | $message | \`$rule\` |" >> pr_lint_summary.md
            done

        if [ "$warning_count" -gt 10 ]; then
            echo "... and **$((warning_count - 10))** more issues" >> pr_lint_summary.md
            echo "" >> pr_lint_summary.md
        fi

        cat >> pr_lint_summary.md << EOF

### 💡 Quick Fixes:

Common issues and solutions:
- **readability-identifier-length**: Use descriptive variable names (3+ chars)
- **modernize-use-auto**: Use \`auto\` for type deduction
- **performance-for-range-copy**: Use references in range-for loops
- **bugprone-unused-raii**: Ensure RAII objects are properly used

💡 **Tip**: Run \`bash cpp/scripts/lint.sh\` locally to see all issues with context.
EOF
    else
        echo "🎉 **Great job!** No code style or quality issues found." >> pr_lint_summary.md
    fi

    cat >> pr_lint_summary.md << EOF

---
*This comment was automatically generated by clang-tidy CI check.*
EOF
}

# Find source files
SOURCE_FILES=$(find . -path "./build" -prune -o -path "./_deps" -prune -o \
    \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -type f -print)

if [ -z "$SOURCE_FILES" ]; then
    echo "No source files found to analyze"
    exit 0
fi

if [ "$PR_MODE" = true ]; then
    # PR mode: parallel processing with Markdown report
    echo "Running lightweight clang-tidy analysis (PR mode)..."

    echo "$SOURCE_FILES" | xargs -I {} -P 6 sh -c "
        $(declare -f run_clang_tidy)
        WIN_ARGS=\"$WIN_ARGS\"
        FILTER_PATTERN=\"$FILTER_PATTERN\"
        run_clang_tidy \"{}\" | sed 's/^/LINT_WARNING: /'
    " > lint_warnings.txt

    WARNING_COUNT=$(grep -c "LINT_WARNING:" lint_warnings.txt || echo "0")
    echo "Found $WARNING_COUNT warnings"

    generate_markdown_report "$WARNING_COUNT" "lint_warnings.txt"
    echo "Report generated: pr_lint_summary.md"

else
    # Local mode: direct batch processing
    echo "Running lightweight clang-tidy analysis..."
    file_count=$(echo "$SOURCE_FILES" | wc -l)
    echo "Running clang-tidy on $file_count files with rules from .clang-tidy..."

    echo "$SOURCE_FILES" | tr '\n' ' ' | xargs clang-tidy $EXTRA_ARGS 2>&1 | \
        grep -vE "$FILTER_PATTERN" | \
        grep -E "warning:"

    echo "Analysis completed"
fi
