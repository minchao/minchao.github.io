# Engine.IO Protocol

原文：https://github.com/socketio/engine.io-protocol

這份文件描述 Engine.IO 協議．關於 JavaScript 的實現，請參考
[engine.io-parser](https://github.com/learnboost/engine.io-parser)，
[engine.io-client](https://github.com/learnboost/engine.io-client)
與 [engine.io](https://github.com/learnboost/engine.io)．

## 修訂版

這是 Engine.IO 的第 **3** 個修訂版．

## Engine.IO session 的分析

1. 傳輸 (transport) 建立一個到 Engine.IO URL 的連線．
2. 服務端回應一個 `open` 封包與使用 JSON 格式編碼的交握資料：
  - `sid` session id (`String`)
  - `upgrades` 可能的傳輸升級 (`String` 型別的 `Array`)
  - `pingTimeout` 服務端 ping 逾時設定, 用於供客戶端檢查服務端是否無回應 (`Number`)
  - `pingInterval` 服務端 ping 間隔時間設定, 用於供客戶端檢查服務端是否無回應 (`Number`)
3. 服務端收到客戶端定期發送的 `ping` 封包時, 必須回應 `pong` 封包．
4. 客戶端與服務端可以任意交換 `message` 封包．
5. 輪詢 (polling) 傳輸可以發送一個 `close` 封包來關閉 socket，因為它們會不斷的執行 "opening" 與 "closing"．

## URLs

一個 Engine.IO 的 url 由以下部分組成：

```
/engine.io/[?<query string>]
```

- `engine.io` 路徑名稱 (pathname) 應該只能被在 engine 之上的更高層次框架改變.

- 查詢字串 (query string) 是可選的, 共有四個保留字可供使用：

  - `transport`：表示傳輸的名稱．預設支援 `polling`, `websocket`．
  - `j`：如果傳輸是 `polling` 且必須使用 JSONP 來回應，則 `j` 必須被設置在 JSONP 回應的索引 (index)．
  - `sid`：如果客戶端已經取得了一個 session id，那這個 id 就必須包含在查詢字串內．
  - `b64`：如果客戶端不支援 XHR2，`b64=1` 就會包含在查詢字串內發送給服務端，表示所有的二進位資料都應該以 base64 編碼來發送．

*FAQ:* `/engine.io` 的 path 是否可以修改？

是的，服務端被設計為可以在不同的 path 下去攔截請求．

*FAQ:* 什麼理由決定了一個 option 會是路徑 (path) 的一部份而不是查詢字串的一部份．換句話說，為什麼 `transport` 不是 URL 的一部份？

慣例上，路徑片段*只是*用來表明一個請求是否該由 Engine.IO 服務的實例來處理．就這樣，它僅僅只是 Engine.IO 的前綴 (`/engine.io`) 與資源 (`default` by default)．

## Encoding

這裡有二種不同的編碼格式

- packet
- payload

### Packet

一個已編碼的封包，可以是 UTF-8 字串或二進位 (binary) 資料．字串形式封包的編碼格式如下：

```
<packet type id>[<data>]
```

範例:

```
2probe
```

二進位資料的編碼也是一樣．當發送二進位資料時，封包的 type id 放在第一個位元，接著是實際的封包資料，如：

```
4|0|1|2|3|4|5
```

在上面的範例中，每個位元以 pipe 字元分隔，並以整數的形式顯示．所以範例的封包是屬於 message type 的封包，且包含對應值為 0, 1, 2, 3, 4, 5 的整數陣列的二進位資料．

封包 type id 為整數．以下為封包的 types 列表：

#### 0 open

當一個新的傳輸連線打開時從服務端發送 (用於核對)．

#### 1 close

請求關閉當前的傳輸，但不會關閉連線本身．

#### 2 ping

從客戶端發送．服務端應該回應一個包含相同資料的 pong 封包．

範例
1. 客戶端發送： ```2probe```
2. 服務端發送： ```3probe```

#### 3 pong

從服務端發送，用來回應客戶端的 ping 封包．

#### 4 message

實際發送的訊息．客戶端與服務端可以透過它們的回呼 (callback) 函式來取得資料．

##### 範例 1

1. 服務端發送: ```4HelloWorld```
2. 客戶端收到訊息並呼其回呼函式 ```socket.on('message', function (data) { console.log(data); });```

##### 範例 2

1. 客戶端發送: ```4HelloWorld```
2. 服務端收到訊息並呼叫其回呼函式 ```socket.on('message', function (data) { console.log(data); });```

#### 5 upgrade

在 engine.io 切換到另一個傳輸前，會先測試服務端與客戶端是否可以在這個新的傳輸上通訊．如果測試成功，客戶端會發送一個 upgrade 封包，
告訴服務端刷新在舊的傳輸上的暫存並切換到新的傳輸上．

#### 6 noop

一個空的封包．主要使用在當收到一個 websocket 連線連入時，強制執行一個輪詢週期．

##### 範例
1. 客戶端透過新的傳輸進行連線
2. 客戶端發送 ```2probe```
3. 服務端接收到訊息並發送 ```3probe```
4. 客戶端接收到訊息並發送 ```5```
5. 服務端刷新暫存並關閉舊的傳輸，然後切按到新的傳輸上．

### Payload

A payload is a series of encoded packets tied together. The payload encoding format is as follows when only strings are sent and XHR2 is not supported:

```
<length1>:<packet1>[<length2>:<packet2>[...]]
```
* length: length of the packet in __characters__
* packet: actual packets as descriped above

When XHR2 is not supported, the same encoding principle is used also when
binary data is sent, but it is sent as base64 encoded strings. For the purposes of decoding, an identifier `b` is
put before a packet encoding that contains binary data. A combination of any
number of strings and base64 encoded strings can be sent. Here is an example of
base 64 encoded messages:

```
<length of base64 representation of the data + 1 (for packet type)>:b<packet1 type><packet1 data in b64>[...]
```

When XHR2 is supported, a similar principle is used, but everything is encoded
directly into binary, so that it can be sent as binary over XHR. The format is
the following:

```
<0 for string data, 1 for binary data><Any number of numbers between 0 and 9><The number 255><packet1 (first type,
then data)>[...]
```

If a combination of UTF-8 strings and binary data is sent, the string values
are represented so that each character is written as a character code into a
byte.

The payload is used for transports which do not support framing, as the polling protocol for example.

## Transports

一個 engine.io 服務端必須支援三種傳輸方式：

- websocket
- polling
  - jsonp
  - xhr

### Polling

The polling transport consists of recurring GET requests by the client
to the server to get data, and POST requests with payloads from the
client to the server to send data.

#### XHR

The server must support CORS responses.

#### JSONP

The server implementation must respond with valid JavaScript. The URL
contains a query string parameter `j` that must be used in the response.
`j` is an integer.

The format of a JSONP packet.

```
`___eio[` <j> `]("` <encoded payload> `");`
```

To ensure that the payload gets processed correctly, it must be escaped
in such a way that the response is still valid JavaScript. Passing the
encoded payload through a JSON encoder is a good way to escape it.

Example JSONP frame returned by the server:

```
___eio[4]("packet data");
```

##### Posting data

The client posts data through a hidden iframe. The data gets to the server
in the URI encoded format as follows:

```
d=<escaped packet payload>
```

In addition to the regular qs escaping, in order to prevent
inconsistencies with `\n` handling by browsers, `\n` gets escaped as `\\n`
prior to being POSTd.

### WebSocket

Payload 編碼 _不應該_ 被使用在 WebSocket 上，因為 WebSocket 協議本身已經具備輕量級的 framing 機制．

發送訊息負載時，請個別編碼封包並接連地 `send()` 它們．

## Transport upgrading

連線經常以輪詢 (XHR 或 JSONP) 的方式開始．WebSocket 透過發送探針 (probe) 的方式進行測試．如果服務端回應探針，則客戶端就會發送 upgrade 封包．

為了確保不丟失任何訊息，只有當目前連線的緩衝區都被刷新且傳輸被認為是 _暫停_ 的狀態，才會送出 upgrade 封包．

當服務端收到 upgrade 封包，它必須假定這是新的傳輸通道並且將目前在緩衝區內的資料都發送給它 (如果有的話)．

客戶端發送的 probe 是一個 `ping` 封包，包含 `probe` 資料．
服務端發送的 probe 是一個 `pong` 封包，包含 `probe` 資料．

後續發展，考慮 `polling -> x` 以外的傳輸升級．

## Timeouts

客戶端必須使用 `pingTimeout` 與 `pingInterval` 作為交握的一部份 (在 `open` 封包中) 來檢查服務端是否無回應．

客戶端發送一個 `ping` 封包後，如果在 `pingTimeout` 的時間內沒有收到任何封包，客戶端應該考慮當前的 socket 已經斷線．
如果確實收到一個 `pong` 封包，則客戶端應等待 `pingInterval` 的時間後在發送另一個 `ping` 封包．

由於這兩個值會在服務端與客戶端間共享．當服務端在等待 `pingTimeout + pingInterval` 的時間後無法收到來自客戶端的任何資料，應要也能夠偵測客戶端是否已無法回應．
