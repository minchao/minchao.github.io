# Git notes

## 小技巧

### 使用 filter-branch 刪除指定資料夾外的修改記錄，例如想將某資料夾拆出成為獨立的版本庫

```console
git filter-branch --prune-empty --tree-filter 'rm -rf FOLDER-NAME/' -- --all
```

See: https://git-scm.com/docs/git-filter-branch
