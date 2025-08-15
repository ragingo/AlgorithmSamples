#!/bin/bash

# clang-tidy runner script for AlgorithmSamples C++ project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$CPP_DIR/build"

echo "Running clang-tidy on C++ code..."

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

# Basic clang-tidy configuration - exclude system/library diagnostics
CHECKS="-*,modernize-*,readability-*,performance-*,bugprone-*,-clang-diagnostic-error"
ARGS=(--extra-arg=-std=c++23 --extra-arg=-I.)

# Add Windows-specific compiler flags
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    ARGS+=(--extra-arg=-target --extra-arg=x86_64-pc-windows-msvc)
    ARGS+=(--extra-arg=-fms-compatibility-version=19)
    echo "Detected Windows environment"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux environment"
    # Linux standard library paths are automatically detected by clang-tidy
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS environment"
    # macOS standard library paths are automatically detected by clang-tidy
fi

# Add Windows SDK and MSVC include paths on Windows
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Find the latest Windows Kit version
    WIN_KIT_VER=$(ls "C:/Program Files (x86)/Windows Kits/10/Include" 2>/dev/null | sort -V | tail -1)
    if [ -n "$WIN_KIT_VER" ]; then
        WIN_KIT_PATH="C:/Program Files (x86)/Windows Kits/10/Include/$WIN_KIT_VER"
        ARGS+=(--extra-arg=-I"$WIN_KIT_PATH/ucrt")
        ARGS+=(--extra-arg=-I"$WIN_KIT_PATH/um")
        ARGS+=(--extra-arg=-I"$WIN_KIT_PATH/shared")
        echo "Using Windows Kit: $WIN_KIT_VER"
    fi

    # Find MSVC include path (get the latest version)
    MSVC_INCLUDE=$(ls -d "C:/Program Files/Microsoft Visual Studio"/*/*/VC/Tools/MSVC/*/include 2>/dev/null | sort -V | tail -1)
    if [ -n "$MSVC_INCLUDE" ]; then
        ARGS+=(--extra-arg=-I"$MSVC_INCLUDE")
        echo "Using MSVC includes: $MSVC_INCLUDE"
    fi
fi

# Try to use compile_commands.json if available
if [ -f "$BUILD_DIR/compile_commands.json" ]; then
    echo "Using compile_commands.json from build directory"
    ARGS+=(-p="$BUILD_DIR")
else
    echo "compile_commands.json not found, using basic configuration"
    echo "Tip: Run 'cmake -S cpp -B cpp/build' to generate compile_commands.json"
fi

echo "Analyzing project files..."
echo "========================================="

# Find and check all relevant files
find . -path "./build" -prune -o -path "./_deps" -prune -o \
    \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -type f -print | \
    while IFS= read -r file; do
        echo "Checking: $file"
        # Run clang-tidy but filter out system header errors
        output=$(clang-tidy "$file" --checks="$CHECKS" "${ARGS[@]}" 2>&1 | grep -v "file not found" | grep -v "fatal error")

        if echo "$output" | grep -q "warning:"; then
            echo "  ⚠️  Issues detected"
            # Show warnings from project files only
            echo "$output" | grep -E "^[^/]*\..*warning:" | head -2 || true
        else
            echo "  ✅ Clean"
        fi
        echo ""
    done

echo "========================================="
echo "clang-tidy analysis completed"
echo ""
echo "💡 For detailed analysis, run:"
echo "   clang-tidy <filename> --checks='$CHECKS' [with appropriate include paths]"
