# The Twelve-Factor App

https://12factor.net/

建構並部署網路應用程式的首要原則。

## I. Codebase

One codebase tracked in revision control, many deploys

- 一個 Codebase 一個應用。
- 分佈式系統內的每個組件都是一個應用，每個應用都可按照 12-Factor 來開發。
- 共享的程式碼應該被拆分為獨立的函式庫，然後使用 Dependencies（依賴管理）來載入。
- 應用通常會有多個執行環境，但都該基於同一份 Codebase 來部署。

:::info
常見的環境分類：

- Local - 開發環境
- Development - 測試環境
- Staging - 預發布環境
- Production - 線上產品環境
:::

## II. Dependencies

Explicitly declare and isolate dependencies

- 透過依賴清單管理依賴，不隱式地依賴系統層級的函式庫。
  - 例如 ImageMagick 及 curl 都很常見的系統工具依賴。
- 使用[語意化版本](https://semver.org/)管理依賴。
- 一些依賴隔離工具可以隔離系統中存在，但是依賴清單中沒有聲明的依賴項目。
- 簡化開發者的環境設定流程。

:::info
系統工具依賴如何管理？

- IaC，如
  - [AWS Cloud Development Kit](https://github.com/aws/aws-cdk)
  - [Puppet](https://github.com/puppetlabs/puppet)
- Docker image
- 程式語言的依賴管理工具
  - 例如 PHP 的 composer.json 可以聲明程式依賴的 PHP extensions
:::

## III. Config

Store config in the environment

- 通常應用的設定在不同部署環境會有很大差異，這些設定會被排除在程式碼之外，包括：
  - 資料庫、快取及其它後端服務的設定。
  - 網域名稱、證書、S3 URL 等。
- 判斷一個應用是否正確將設定排除的簡單方法，是否可以立刻開放原始碼，而無需擔心暴露任何敏感訊息。
- 使用設定檔。
  - 不簽入版本控制系統內。
    - [.gitignore](https://git-scm.com/docs/gitignore)
  - 設定檔與部署機制在獨立的版本庫管理。
  - 將設定按環境分組。
- 將設定儲存在環境變數中。
  - 透過工具進行管理：
    - [AWS System Manager - Parameter Store](https://aws.amazon.com/tw/systems-manager/features/)
    - [AWS Secrets Manager](https://aws.amazon.com/tw/secrets-manager/)
    - [HashCorp - Vault](https://www.hashicorp.com/products/vault/)
- 混合使用設定檔與環境變數。

:::info
Dot env file 是常見的實踐。

- npm [dotenv](https://github.com/motdotla/dotenv)
- PHP [symfony/dotenv](https://github.com/symfony/dotenv)
- [Docker compose .env](https://docs.docker.com/compose/environment-variables/#the-env-file)
:::

## IV. Backing services

Treat backing services as attached resources

- 後端服務是指需要透過網路呼叫的各種服務，如 Database、Queue、SMTP、Cache 等，可能包含本地與第三方服務。
- 不會區別本地或第三方後端服務，它們都是透過 URL 來呼叫，保持鬆散耦合。
- 在不修改應用程式碼的情況，應該可以透過修改設定替換其後端服務，例如本地 MySQL 替換成第三方 Amazon RDS。

## V. Build, release, run

Strictly separate build and run stages

- 將 Codebase 轉化為部署的三個階段：
  - Build，將程式碼轉為可執行檔案的過程，build 時會使用者定版本的程式碼，取得依賴套件，再編譯成可執行檔和資源。
  - Release，將打包結果與設定檔結合，並準備好在執行環境中執行。
  - Run，在執行環境中執行應用程序。
- 部署工具通常會提供發布管理機制，特別是 Rollback 功能。
- 每個發布版本都會有唯一的 ID，一但發布就不可更改，任何更動都應該產生一個新的發佈版本。
- Run 階段應該保持盡可能少的活動組件，因為應用可能會在開發人力缺乏的時段發生故障。
- Build 階段可以複雜一些，盡可能將錯誤訊息立刻呈現在開發人員面前。

## VI. Processes

Execute the app as one or more stateless processes

- 執行環境中，應用通常是以一個或多個行程執行。
- 應用行程必須是無狀態且無共享，任何持久化數據都儲存在後端服務內。
- 不需要考慮進程的快取內容是不是可以保留給之後的請求使用，因為將來的請求會轉由其它行程來服務。
- 不應該依賴 sticky session。

## VII. Port binding

Export services via port binding

- 網路應用有時會在 web 服務器內執行
  - 例如 [PHP 透過 mod_php 作為 Apache 的模組來執行](https://z-issue.com/wp/apache-2-4-the-event-mpm-php-via-mod_proxy_fcgi-and-php-fpm-with-vhosts/)。
  - Java 在 Tomcat。
- 12-Factor 應用不依賴任何 web 服務器，直接透過 prot binding 提供服務。
- Port binding 可以讓一個應用成為另一個應用的後端服務，透過 URL 呼叫，並儲存在設定檔以應對不同的環境部署。

## VIII. Concurrency

Scale out via the process model

- 網路應用採用多種行程執行方式。
  - PHP 作為 Apache 的子行程，按需要啟動。
  - JVM 啟動時事先準備系統資源，內部透過執行緒管理並行。
- 對應用的開發人員來說，行程是最小的管理單位。
- 使用 Unix process model 設計應用架構，容易擴展。
- 借助系統的行程管理器（如 systemd）來管理行程。
  - Output streams
  - Crashed process
  - User-initiated restart and shutdown
    - Graceful shutdown
  
## IX. Disposability

Maximize robustness with fast startup and graceful shutdown

- 12-Factor 應用的行程應該是易處理的，可以瞬間啟動或停止。這有利於快速、彈性地伸縮應用。
- 行程收到終止信號（SIGTERM）就應該 Graceful shutdown。
  - Web，停止監聽 port，拒絕新請求，繼續執行當前的請求，然後退出。
  - Worker，將 job 退回 queue，job 應該可重複執行。
- 面對突然的故障仍能保持健壯性。
  - Queue

## X. Dev/prod parity

Keep development, staging, and production as similar as possible

- 盡可能保持開發環境與線上環境相同。
  - 縮短交付時間。
  - 開發人員應該熟悉部署過程及產品執行環境。
  - 保持開發環境與線上環境的一致性。
- 在不同環境使用相同的後端服務。

## XI. Logs

Treat logs as event streams

- 12-Factor 應用從不路由或儲存自己的輸出串流（output stream），每個執行中的行程都會無緩衝地將事件串流寫入 `stdout`。
- 將輸出串流發送到日誌索引或分析系統。

## XII. Admin processes

Run admin/management tasks as one-off processes

- 管理任務行程。
  - Database migrations
  - REPL script
  - One-time git commit
- 一次性的後台管理任務，也該跟正常的常駐行程一樣對待。

## 其它參考資料

- [Erosion-resistance & Explicit Contracts](https://blog.heroku.com/the_new_heroku_4_erosion_resistance_explicit_contracts)
- [Golang configuration in 12 Factor application](https://blog.container-solutions.com/golang-configuration-in-12-factor-applications)
