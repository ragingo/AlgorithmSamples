# より高度なPRコメント機能の追加案

## 現在の実装
- ✅ PRに要約コメントを自動投稿
- ✅ ファイル別の問題数表示
- ✅ サンプル警告の表示
- ✅ 既存コメントの更新

## さらなる改善案

### 1. 行単位の正確なコメント
現在の実装では、PRの一般コメントとして投稿していますが、
より正確な行単位コメントを付けるには以下のような専用アクションを使用できます：

```yaml
- name: Run clang-tidy with reviewdog
  uses: reviewdog/action-clang-tidy@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    workdir: cpp
    tool_name: clang-tidy
```

### 2. SARIF (Static Analysis Results Interchange Format) 対応
GitHub の Code Scanning と統合して、より詳細な解析結果を表示：

```yaml
- name: Upload SARIF results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: clang-tidy-results.sarif
```

### 3. 差分のみの解析
PRで変更された行のみをチェックして、無関係な警告を除外：

```bash
git diff --name-only origin/main...HEAD | grep -E '\.(cpp|hpp|h)$'
```

現在の実装でも十分実用的ですが、必要に応じてこれらの機能も追加できます。
