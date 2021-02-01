---
tags: zero-trust-network
slideOptions:
  transition: slide
---

# Zero Trust Network

---

## 大綱

- 關於信任
- 傳統網路安全架構
  - 傳統網路安全架構面臨的威脅
- 什麼是零信任網路？

Note:
> 起源 2010，BeyondCorp 2014。
> 除了 Google、Netflix，各雲端平台已經在使用零信任的概念，AWS IAM、GCP Identity-Aware Proxy。
> 甚至還有許多現成的商業[解決方案](https://www.g2.com/categories/zero-trust-networking)

---

## 關於信任

Zero Trust is a paradigm shift from "trust, but verify" to "never trust, always verify"

Note:
> 網路安全其實是 ...
> 面對當前網路安全威脅的典範轉移。

---

## 傳統的網路安全架構

多依靠 Perimeter security model（邊界安全模型，例如防火牆）來保護內部資源

Note:
> 透過防火牆來的建立邊界。

---

![](https://i.imgur.com/rqvTQ84.png)

網路依信任劃分為不同的區域，區域間使用防火牆隔離

Note:
> 每個區域都被授與不同層度的信任，例如公司內的網路被分為放置 Load blancer 的 DMZ、App server 的信任環境與敏感資源的特權環境，作為邊界的防火牆決定了哪些資源允許被訪問。
>
> 說明 [Demilitarized zone (DMZ)](https://en.wikipedia.org/wiki/DMZ_(computing))，後面攻擊手法會介紹怎麼繞過。

---

![](https://i.imgur.com/rqvTQ84.png)

提供強大的縱深防禦能力

Note:
> 得過好幾道關卡。

---

換個角度來看邊界安全模型，其實就像“城堡”

![](https://nigesecurityguy.files.wordpress.com/2013/06/defense-in-depth.jpg)

- 周圍有厚實的堡壘，被護城河圍繞。
- 有嚴格保護的出入口過濾所有的進出者。
- 牆外的東西被認為是危險的，而牆內的東西被認為是可信任的。
- 入侵者必須穿透防線，才能抵達受保護的敏感資源。
- 預設信任內網中的使用者、裝置及應用程式，雙方在相同網路內，就可以互相通信。
- 基於信任，網路內的通信不一定會加密。
- 當網路開始變大或區分不同等級的信任，我們會將網路切割出更小的子網路。
- 假設特定使用者和服務之間存在精確的邊界。

> Note:
>
> - 網路內的服務間彼此溝通時會使用 HTTP 或某種 RPC，但通常流量沒有經過加密、身份及授權驗證，因為我們預設信任網路內的服務。舉例。
> - 當網路開始變大，或新增不同的信任等級（例如切分產品及測試環境），我們會開始將網路分段為更小的子網路，並在子網路間透過防火牆過濾。
>
> 真實場景的架構圖通常會有非常複雜的防火墻規則（找張示意圖）。

---

## 傳統網路安全架構面臨的威脅

---

外部攻擊

- 對攻擊者而言成本很高

Note:
> 如今我們很難沒有網際網路的情況下工作，所以很難將外部的流量完全隔離，但是得益於邊界安全模型長久以來的發展，對攻擊者而言，穿透層層防禦，由外部攻擊的成本非常高。

---

內部威脅

- 釣魚、木馬及社交工程攻擊等
- 缺乏同一網路內部的流量檢查
- 安全策略總是存在例外

Note:
> 相對，轉而從內部攻擊，透過釣魚郵件、木馬等方法滲透到網路內部比較容易。內網是可信任的，一但突破安全邊界進入內網，可能就會透過安全策略例外取得敏感資源的訪問權限（例：開發或維運會想透過 SSH 訪問 Web，或訪問 DB，防火牆就會配置這些例外，允許某個 IP 訪問特定伺服器。）。
>
> 所以，攻擊者不一定在外部，位於內部網路的員工也可能在不知情的狀況下成為攻擊跳板，攻擊者攻陷內部節點後，再橫向移動尋找高價值的節點。

---

## 橫向移動攻擊

攻擊者透過在內網橫向移動，最終進入產品網路

Note:
> 我們來看看一個實際的橫向攻擊例子。

---

![](https://i.imgur.com/p946suf.png)

1. 通過釣魚郵件鎖定企業的員工（例如偽裝成折價卷）
2. 攻陷辦公室網路內的電腦，取得 Shell 執行權限
3. 在辦公室網路內橫向移動
4. 定位擁有特權的員工
5. 安裝鍵盤側錄軟體
6. 竊取密碼
7. 從擁有特權員工的電腦攻擊產品主機
8. 利用竊取的密碼在產品應用程式主機上操作
9. 從應用程式中取得資料庫密碼
10. 通過被攻陷的應用程式主機外洩資料庫中的數據

> 實際案例：[一銀 ATM 遭駭事件](https://www.ithome.com.tw/news/107294)

Note:
> 成功繞過了 DMZ。

---

## 什麼是零信任網路？

---

零信任網路的五個基本原則

- 網路永遠處在危險的環境中
- 網路始終存在外部和外部威脅
- 網路的位置不足以決定其可信任程度
- 所有的使用者、裝置和網路流量都應經過認證和授權
- 安全策略應該是動態的，並基於盡可能多的資料來源計算而來

Note:
> 零信任反思傳統安全架構不足，基於以下假定來建立安全防護機制。 首先，網路永遠處在危險的環境之中，且這些危險來源不分內外。
>
> 裝置 IP 位置與所在網路不再決定其是否可被信任。取得代之，所有的使用者、裝置與網路流量都應該經過嚴格的認證和細粒度的授權控制，才可以訪問受保護的資源。
>
> 授權基於 Network agent。
> 也就是說，零信任網路讓安全架構體系由原本的以網路為中心，走向以身份為中心進行細粒度的訪問控制的機制。

---

應用零信任網路建構的網路安全架構

![](https://i.imgur.com/a1crTA2.png)

Control plane 支撐整個系統的身份驗證與授權檢查

Note:
> 這張圖呈現的是應用零信任網路建構的網路安全架構，我們可以看到畫面上方是支撐整個系統的 [Control plane](https://en.wikipedia.org/wiki/Control_plane)（控制平面/層），而其它部分稱為 [Data plane](https://en.wikipedia.org/wiki/Data_plane)（資料平面/層）。
>
> Control plane 與 Data plane 是網路系統經常使用的概念，Control plane - 相當於網路裝置的大腦，用來配置管理網路裝置。
>
> 大腦、神經、四肢。

---

![](https://i.imgur.com/a1crTA2.png)

- 其餘 Data plane 的服務都接受 Control plane 的控制，待確認請求合法後才允許被訪問
- 不再有信任與非信任網路之分

Note:
> Data plane - 負責轉發流量。
>
> 例如遠端工作的員工，想訪問 Private service 或 Secure gateway 背後的 Legacy service。首先會經過 Control plane，其確保請求會經過認證身分與檢查授權，只有當請求具備合法的授權，才會允許 Data plane 接受請求，訪問受保護的資源。

---

## 認證

所有的訪問請求都必須被認證

- 你是誰？
- 如何證明？

---

- 通常會採取集中式的身份認證與授權機制，例如常見的 OAuth 2 及 SAML 協議
- 採用密碼學方法對使用者、裝置或應用的身份進行認證

Note:
> 數位簽章，不可否認性。例如自然人憑證、工商憑證。

---

## 授權

所有的訪問請求都必須被授權，並採用最低權限策略

- 要去哪裡？
- 要做什麼？
- 有權限嗎？

Note:
> 那麼授權策略該如何制定？

---

授權策略基於 Network Agent 來制定

- 使用者
- 裝置
- 應用程式

Note:
> Network Agent 是請求發起者屬性的一個集合，通常包含使用者、裝置與應用程式這三類實體。傳統上這些實體會被單獨授權（譬如授權某個使用者訪問），但零信任網路中，授權策略是基於這三種實體的屬性來制定，以有效對抗憑證遭竊取等安全威脅。
>
> 例子，手機、App、使用者。

---

授權體系架構

![](https://i.imgur.com/VOjJlfG.png)

Note:
> 授權是零信任網路的核心機制，網路中的所有請求都會經過授權檢查才會被放行，授權機制的架構大致上可分為四個部分，其職責各不相同。

---

Enforcement（策略執行組件）

![](https://i.imgur.com/VOjJlfG.png)

- 會直接影響授權決策結果
- 通常由 Load balancer、Proxy 或 Firewall 擔任

Note:
> 首先 Enforcement 是整個零信任網路中最常見的，會大量部署在系統，直接影響授權決策的結果，所以它的位置非常重要，應該盡可能靠近 Data plane 網路流量。
>
> 類比執行法律的執法人員。

---

![](https://i.imgur.com/VOjJlfG.png)

負責將請求的上下文傳遞給 Policy engine，並確保請求會經過認證

Note:
> 當一個請求被發往由 Enforcement 所保護的資源端點，Enforcement 會負責將請求的上下文傳遞給 Policy engine 進行交互，並確保請求會經過認證。

---

Policy engine（策略引擎）

![](https://i.imgur.com/VOjJlfG.png)

實際進行授權決策的組件，將請求與事先定義的策略進行比較，決定是否允許

Note:
> Policy engine 會根據事先定好的策略，並參考 Trust engine 的各種數據來完成授權決策。
>
> 已經有一些現成的選擇，例如 [Open Policy Agent (OPA)](https://www.openpolicyagent.org/)。

---

Trust engine（信任引擎）

![](https://i.imgur.com/VOjJlfG.png)

對請求或活動進行風險分析的組件

---

![](https://i.imgur.com/VOjJlfG.png)

透過演算法基於請求所代表實體（使用者、裝置或應用程式）的各種屬性值進行信任風險評分

Note:
> Trust engine 會根據請求所代表實體（使用者、裝置或應用程式）的各種屬性（例如，裝置的系統更新時間、IP、甚至安全紀錄等資訊），透過演算法來計算分析評分。
>
> 舉例

---

Data stores（資料儲存系統）

![](https://i.imgur.com/VOjJlfG.png)

實際存放授權決策所依據的策略與數據的組件

Note:
> 而圖片最上面的 Data stores 就是是實際存放授權決策所依據的策略與數據的地方。
>
> 推薦使用 Git 來儲存 Policies，讓變更可以被追蹤，甚至重建回某一時間點的狀態。

---

小提醒：

採用集中式身份認證與授權機制時，並不意味著應用服務完全不需要具備授權能力，服務應該保留細粒度的授權操作，以應對使用者權限經常變化的情況

Note:
> 粗粒度，例如觀看資料的 API 可以看幾筆。

---

## 邊界安全模型與零信任模型對比

---

傳統模型

- 試圖在可信任和不可信任的資源間建立一道牆，而零信任模型則接受“壞人”無處不再在的現實
- 僅在網路邊界執行安全控管，而零信任模型可以在每個服務前把關
- 遭受攻擊時的爆炸半徑較大

Note:
> 因為同一網段內的服務互相信任。

---

零信任模型

- 對網路流量進行加密處理
- 採用密碼學技術對身份進行驗證，不在意連線的來源 IP 位址
- 透過授權策略與信任評分，可以執行靈活且細粒度的訪問控制

---

## 心得

- 應用程式開發者也應該認識到威脅無所不在
- 即使在應用層也可以建立安全防護機制

Note:
> 從邊界安全模型轉移到零信任模型，工程浩大非常不易，因為零信任網路不是一種技術，而是安全策略。
> 不應該期待採用某一個解決方案後就可以直接轉換，應該視企業內部的架構，採逐步補強的方式，來填補傳統邊界安全模型中不足的部分。

---

## 參考資料

- [Zero Trust Network](https://www.oreilly.com/library/view/zero-trust-networks/9781491962183/)
- [BeyondCorp](https://cloud.google.com/beyondcorp#researchPapers) - A New Approach to Enterprise Security
- [Google Cloud - Cloud Identity-Aware Proxy](https://cloud.google.com/iap/)
- [ORY Oathkeeper](https://github.com/ory/oathkeeper) - Identity and Access Proxy
- [Open Policy Agent](https://www.openpolicyagent.org/) - Policy-based control
- [Digital signature](https://en.wikipedia.org/wiki/Digital_signature)
