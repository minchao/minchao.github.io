# 系統改寫筆記

一些閱讀系統改寫案例的筆記。

案例：

- [Khan](#Khan)
- [Zhihu](#Zhihu)
- [An Agile Approach to a Legacy System](#An-Agile-Approach-to-a-Legacy-System)

## Khan

[Khan](https://www.khanacademy.org/) 是非營利線上教學機構。

將既有的 Python 2 服務遷移到 Golang（進行中）- [Go + Services = One Goliath Project](https://engineering.khanacademy.org/posts/goliath.htm)。

### 為什麼要改寫

- Python 2 即將死亡，換成 3 的好處不夠多。
- [開始重視品質](http://engineering.khanacademy.org/posts/eng-principles-help-scale.htm)。
- 提高性能，更低的資源使用。
  讓錢燒慢一點。
- 微服務
  - 獨立部署與測試，更快修改。
  - 單一服務的問題對其它部分的影響有限。
  - 方便最佳化性能與成本。

### 不變的部分

- 輸出入（先將舊程式碼遷移到 GraphQL）。
- 業務邏輯。
- 資料庫。

### 作法

- **打掃房子**，**重構既有 Python 2 程式碼**，使其更容易移植到 Go。
  - 先完成從 SSR 到 SPA 的轉換（前後端分離，React + GraphQL）。
  - [程式碼擺放混亂，毫無結構，先打掃](http://engineering.khanacademy.org/posts/python-refactor-1.htm)
    - 為什麼會變成這樣？
      **破窗效應。**
    - 怎麼做？
      - **下定決心先還技術債**。
    - 困難點？
      - 雖然搬移工具的效果很好，但許多模凌兩可的部分需要花時間投入代碼審查。
      - 解決合併衝突。
      - 引用路徑問題，程式碼搬移後，路徑中斷了。
  - [工欲善其事，必先利其器](http://engineering.khanacademy.org/posts/slicker.htm)
    - 打造用來搬移程式碼的工具。
      **請先確定沒有現成的工具可以幫你。**
  - [處理依賴問題](http://engineering.khanacademy.org/posts/python-refactor-3.htm)
    - 順序，lower-level 套件不應該依賴 higher-level 套件。
      **看看洋蔥架構，依賴是由外向內，內層的程式碼不應該知道外層的任何東西。**
    - 循環依賴
    - 工具
      - 靜態分析。
      - 依賴關係圖。
        可以看一下改善前後的比較，線變少了，也沒那麼複雜。
- 建立 GraphQL Gateway
  - 2 年前就開始慢慢將 HTTP API 遷移到 GraphQL。
  - 使用 [GraphQL Federation](https://blog.apollographql.com/apollo-federation-f260cf525d21)。
    - 將請求分派到服務（新服務或過度期的 Python 服務） 。
- Go。
  打底完後，目前已**逐步遷移**了少量服務，2020 將繼續改寫。

## Zhihu

[知乎](https://www.zhihu.com/) 是一個問答社群網站。

將知乎社區核心業務（Python）用 Go 改寫。

https://zhuanlan.zhihu.com/p/48039838

### 為什麼要改寫

- 流量太大，執行效率低，在 Python 的最佳化努力榨不出更多效能。
  **太燒錢。**
- 動態語言的維護成本高。
  > Python 过于灵活的语言特性，导致多人协作和项目维护成本较高。
  - 執行時期才能確定型別。

不變的部分：

- 輸出入。
- 業務邏輯。
- 後端資源（如，DB）。

### 作法

分階段改寫及發布。

- 使用靜態語言對**資源佔用高**的業務進行改寫。
  - 還是保留許多 Python 的部分。
- 使用 Go 重寫一個業務邏輯
  - 輸出入不變。
    > 新服务对外暴露的协议（HTTP 、RPC 接口定义和返回数据）与之前保持一致（保持协议一致很重要，之后迁移依赖方会更方便）
  - 後端資源不變。
- 驗證改寫後邏輯的正確性
  - 冪等，在老服務收到請求時，起一個協程請求新服務，比對，否，則紀錄。
  - 非冪等：
    - 單元測試。
    - 開發者驗證。
    - QA。
  - **SQL 語法，比對改寫後是否相同。**
- 灰度發布。
  - 請求一樣發到老服務，但不處理，而是轉到發新服務。
  - 按百分比轉發流量。
  - 遇到問題就 rollback。
  - 這時後端資源還在老服務手上。
- 100%
  - 沒問題，路由可以從入口直接切到新服務。
  - 將後端資源轉由新服務接手管理。

### 如何確保改寫的正確性

- 不要無腦翻譯，但也不能無腦修復。
  **如果沒有原作者參與，信心不夠，最好還是先在老版本修復。**
- **專案結構要花時間慢慢調整**。
  - **依賴管理很重要**。
  - 怎麼做才會讓 mock 好寫？
  - 最後可以建立 project layout template。
- 盡可能提早做程式碼靜態檢查。

### 其它

- 服務降級的顆粒度，按功能。
  - 如果這個功能不可用，對用戶的影響是什麼？
  - 例如，即使問答依賴的 RPC 都掛了，問答本身仍可以瀏覽。

- **不推薦使用它的錯誤處理方式。**
  - 知乎的實現，在其它語言是很常見的作法，但 Go 的 panic 是用在 package 內的緊急情況，最終還是會返回適當的 error。
https://blog.golang.org/defer-panic-and-recover

## An Agile Approach to a Legacy System

http://cdn.pols.co.uk/papers/agile-approach-to-legacy-systems.pdf
