# Golang YAML

由於 Go 的標準庫並沒有提供原生 YAML 庫，大部分的使用者都使用第三方庫來處理，簡單介紹幾個第三方庫的關係與 deserialize 格式。

## [go-yaml](https://github.com/go-yaml/yaml)

最常見的 YAML 庫，需要注意 v2 和 v3 版本格式有很大的不同：

v2 縮排使用 2 空格，列表使用方括號

```yaml
a: Easy!
b:
  c: 2
  d: [3, 4]
```

v3 縮排使用 4 空格，列表縮排

```yaml
a: Easy!
b:
    c: 2
    d:
        - 3
        - 4
```

## [ghodss/yaml](https://github.com/ghodss/yaml)

對 go-yaml v2 的再包裝，會沿用 JSON struct 的標籤，方便同時處理 JSON 和 YAML，但目前已經停止維護。

```yaml
a: Easy!
b:
  c: 2
  d:
  - 3
  - 4
```

## [kubernetes-sigs/yaml](https://github.com/kubernetes-sigs/yaml)

由 kubernetes-sigs 維護的 ghodss/yaml 版本，在 kubernetes 生態圈被廣泛使用。

```yaml
a: Easy!
b:
  c: 2
  d:
  - 3
  - 4
```
