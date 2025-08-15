# C++アルゴリズムサンプル集

このディレクトリには、C++で実装されたアルゴリズムのサンプルコードが含まれています。

## 📝 プロジェクトの概要

AlgorithmSamplesは、様々なアルゴリズムを学習・実践するためのC++プロジェクトです。各アルゴリズムは独立したデモとして実装され、統一されたランナー実行ファイル `algorithms_runner` を通じて実行できます。

### 特徴

- [x] **統一実行環境**: 単一のランナー実行ファイルで複数のアルゴリズムデモを実行
- [x] **自動登録システム**: `REGISTER_DEMO` マクロによる自動デモ登録
- [x] **ベンチマーク機能**: `--bench` オプションによる実行時間測定
- [x] **堅牢なエラーハンドリング**: 詳細なエラーメッセージと例外処理
- [x] **包括的テスト**: Catch2フレームワークによる単体テスト
- [x] **最新C++標準**: C++23対応

## 🔧 必要な環境

- **CMake**: 4.0以上
- **コンパイラ**: C++23対応コンパイラ
  - Visual Studio 2022 (Windows) - Windows SDKが必須
  - GCC 11以上 (Linux)
  - Clang 14以上 (macOS)

## 🚀 ビルド方法

### 基本ビルド

```bash
# プロジェクトルートで実行
cmake -S cpp -B cpp/build
cmake --build cpp/build --config Release
```

### Windows（Visual Studio）での推奨ビルド手順

1. Developer Command Promptを起動するか、`VsDevCmd.bat`を実行してMSVCツールチェーンを有効化
2. 以下のコマンドを実行：

```bash
mkdir -p cpp/build
cmake -S cpp -B cpp/build
cmake --build cpp/build --config Release
```

### VSCodeでのビルド・実行

このプロジェクトには `.vscode/tasks.json` が含まれており、VSCode上で直接ビルド・実行が可能です：

**ビルドタスク:**
- `[cpp] CMake: Configure` - CMakeプロジェクトの設定
- `[cpp] CMake: Build (Release)` - Releaseビルドの実行
- `[cpp] CMake: Clean` - ビルド成果物のクリーンアップ

**実行・テストタスク:**
- `[cpp] Run algorithms_runner` - アルゴリズム実行（クロスプラットフォーム対応）
- `[cpp] Run algorithms_tests` - テスト実行（クロスプラットフォーム対応）
- `[cpp] CTest: Run all tests` - CTestによる詳細テスト実行

**クロスプラットフォーム対応:**
- **Windows**: Bashシェル対応（Git Bash, WSL等）、相対パス使用
- **macOS/Linux**: ネイティブシェル対応
- 実行ファイルの拡張子（`.exe`）は自動的にWindows環境のみで適用

**実行方法:**
1. `Ctrl+Shift+P` でコマンドパレットを開く
2. `Tasks: Run Task` を選択
3. 実行したいタスクを選択

## 📋 実行方法

### 利用可能なデモの一覧表示

```bash
# パラメータなしで実行すると利用可能なデモが表示される
./cpp/build/Release/algorithms_runner

# 出力例:
# Available demos:
# 0: bubble
# Select demo index (0-0) and press Enter:
```

### デモの実行

#### 方法1: デモ名で実行
```bash
./cpp/build/Release/algorithms_runner bubble
```

#### 方法2: インデックス番号で実行
```bash
./cpp/build/Release/algorithms_runner 0
```

#### 方法3: インタラクティブモード
```bash
./cpp/build/Release/algorithms_runner
# プロンプトでインデックス番号を入力
```

### ベンチマーク実行

```bash
# 実行時間を測定（どのアルゴリズムでも使用可能）
./cpp/build/Release/algorithms_runner [algorithm_name] --bench

# 例: バブルソートのベンチマーク
./cpp/build/Release/algorithms_runner bubble --bench

# 出力例:
# 1 2 3 4 5 ... 9998 9999 10000
# Elapsed: 0.124 s
```

## 🧪 テスト実行

### テストビルドと実行

```bash
# テスト機能を有効にしてビルド
cmake -S cpp -B cpp/build -DBUILD_TESTS=ON
cmake --build cpp/build --config Release

# テスト実行
./cpp/build/tests/Release/algorithms_tests

# CTestを使用した詳細テスト
ctest --test-dir cpp/build -C Release --output-on-failure
```

### テスト出力例

```
Randomness seeded to: 1670134069
===============================================================================
All tests passed (4 assertions in 4 test cases)
```

## � コード品質チェック (Linter)

このプロジェクトでは `clang-tidy` を使用してコードの静的解析を行っています。

### 前提条件

clang-tidyのインストールが必要です：

- **Windows**: LLVM/Clangツールチェーンをインストール
- **Ubuntu**: `sudo apt install clang-tidy`
- **macOS**: `brew install llvm`

### リンターの実行

#### コマンドラインから実行

```bash
# プロジェクトルートで実行
./cpp/scripts/lint.sh

# CI用（詳細なレポート付き）
./cpp/scripts/lint-ci.sh
```

#### VSCodeタスクから実行

VSCodeで `Ctrl+Shift+P` を押して "Tasks: Run Task" を選択し、 `[cpp] Run clang-tidy` を実行してください。

#### CI/CD

このプロジェクトでは、**コメント駆動CI**を採用してvCPU時間を節約しています。PRコメントで特定のキーワードを投稿することで、必要なチェックのみを実行できます。

**使用方法:**
- `@github-actions build` - ビルド・テスト実行
- `@github-actions lint` - コード品質チェック
- `@github-actions format` - フォーマットチェック  
- `@github-actions coverage` - カバレッジ測定
- `@github-actions ci_all` - 全てのチェック実行

または `/ci` でも反応します：
- `/ci build`
- `/ci lint`
- `/ci format`
- `/ci coverage` 
- `/ci ci_all`

**自動実行の有効化:**
vCPU時間を気にしない場合は、`.github/workflows/cpp-ci.yml`のコメントアウトを解除し、`.github/workflows/cpp-ci-comment.yml`を無効化することで従来の自動CI実行に戻せます。

### 設定ファイル

- `.clang-tidy`: clang-tidyの設定ファイル
  - アルゴリズム学習プロジェクトに適したルールセットを定義
  - 厳しすぎるルールは無効化し、学習に集中できる設定

### リンターチェック項目

- **モダンC++の推奨事項**: C++の最新機能の適切な使用
- **パフォーマンス**: パフォーマンス上の問題の検出
- **バグ検出**: 潜在的なバグやメモリリークの検出
- **可読性**: コードの可読性向上のための提案
- **セキュリティ**: セキュリティ上の問題の検出

## �📂 プロジェクト構造

```
cpp/
├── CMakeLists.txt          # メインのCMake設定
├── README.md              # このファイル
├── .clang-tidy            # clang-tidyの設定ファイル
├── main.cpp               # ランナーアプリケーションのメイン
├── demo_registry.hpp      # デモ登録システムのヘッダー
├── demos/                 # デモの実装
│   └── sort/
│       └── bubble_sort.cpp
├── scripts/               # ビルド・開発用スクリプト
│   ├── format.sh          # コードフォーマッター実行
│   ├── check-format.sh    # フォーマットチェック
│   ├── add-bom.sh         # BOM追加
│   └── lint.sh            # clang-tidy実行 (新規追加)
├── sort/                  # アルゴリズムのヘッダー
│   └── bubble_sort.hpp
├── tests/                 # テストコード
│   ├── CMakeLists.txt
│   └── sort/
│       └── test_bubble_sort.cpp
└── build/                 # ビルド出力（生成される）
    ├── Release/
    │   └── algorithms_runner.exe  # メイン実行ファイル
    └── tests/Release/
        └── algorithms_tests.exe   # テスト実行ファイル
```

**注意**: `.vscode/tasks.json`はプロジェクトルートにあり、VSCodeタスクの設定を管理しています。

## 📚 現在実装されているアルゴリズム

### ソートアルゴリズム

| アルゴリズム | デモ名 | 時間計算量 | 空間計算量 | 特徴 |
|-------------|--------|------------|------------|------|
| バブルソート | `bubble` | O(n²) | O(1) | 隣接要素の比較・交換 |

## 🔨 新しいアルゴリズムの追加方法

### 1. ヘッダーファイルの作成

```cpp
// sort/new_algorithm.hpp
#pragma once
#include <iterator>

template<typename Iterator, typename Comparator = std::less<>>
void new_algorithm(Iterator begin, Iterator end, Comparator comp = {}) {
    // アルゴリズムの実装
}
```

### 2. デモファイルの作成

```cpp
// demos/sort/new_algorithm.cpp
#include "demo_registry.hpp"
#include "sort/new_algorithm.hpp"
#include <iostream>
#include <vector>

static void new_algorithm_demo(const std::vector<std::string>& args) {
    std::vector<int> data = {5, 2, 8, 1, 9, 3};
    new_algorithm(data.begin(), data.end());
    
    for (int value : data) {
        std::cout << value << " ";
    }
    std::cout << "\n";
}

REGISTER_DEMO(new_algorithm, new_algorithm_demo);
```

### 3. テストファイルの作成

```cpp
// tests/sort/test_new_algorithm.cpp
#include <catch2/catch_test_macros.hpp>
#include "sort/new_algorithm.hpp"

TEST_CASE("新アルゴリズム - 基本テスト") {
    std::vector<int> v = {5, 2, 8, 1, 9};
    new_algorithm(v.begin(), v.end());
    REQUIRE(v == std::vector{1, 2, 5, 8, 9});
}
```

### 4. ビルドと確認

```bash
cmake --build cpp/build --config Release
./cpp/build/Release/algorithms_runner
```
