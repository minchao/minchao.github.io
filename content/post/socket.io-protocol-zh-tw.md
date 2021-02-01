# socket.io-protocol

原文：https://github.com/socketio/socket.io-protocol

這份文件描述 Socket.IO 協議，關於 JavaScript 的實現，請參考
[socket.io-parser](https://github.com/learnboost/socket.io-parser)
[socket.io-client](https://github.com/learnboost/socket.io-client) 與
[socket.io](https://github.com/learnboost/socket.io) 。

## 協議版本

**目前的協議修訂版：** `4`

## Parser API

### Parser#Encoder

物件，將 socket.io 封包編碼成 engine.io 可傳輸的形式。它唯一擁有的公開方法是 Encoder#encode。

#### Encoder#encode(Object:packet, Function:callback)

將 `Packet` 物件編碼成 engine.io 相容編碼的陣列。如果物件是單純的 JSON，那麼陣列將只包含單一個 socket.io 編碼的字串元素。
如果物件包含二進位資料 (ArrayBuffer, Buffer, Blob 或 File)，那麼陣列的第一個元素將是一個與封包相關的原數據 (metadata) 的字串與
封包內二進位資料被替換為佔位符 (placeholders) 的 JSON。接下來的元素則是對應前述的佔位符的原始二進位資料，

回呼函式唯一的參數是編碼後的陣列。在 socket.io-parser 的實現中，回呼函式會將陣列中每個元素寫入 engine.io 傳輸。
在任何的實現下，陣列中的每個元素都應該是按順序傳輸的。

### Parser#Decoder

物件，將從 engine.io 來的資料解碼成完整的 socket.io 的封包。

解碼器預期的工作流程是在收到任何從 engine.io 進來的編碼後，呼叫 `Decoder#add` 函式並聽取 (listen) 解碼器的 'decoded' 事件以便處理解碼後的封包。

#### Decoder#add(Object:encoding)

將從 engine.io 傳輸收到的一個編碼物件解碼。處理非二進制封包時，一個 encoding 參數被會用來重建完整的封包。
如果封包格式是 `BINARY_EVENT` 或 `ACK`，那麼就會有額外的 add 函式呼叫，用來處理原始封包的二進位資料片段。
一直到將最後的二進位資料編碼傳送給 add 函式處理完，才完成整個 socket.io 封包的重建。

在封包完全解碼後，解碼器會發送一個 'decoded' 事件 (經由 Emitter) 包含一個唯一的參數，即解碼後的封包。
這個事件的聆聽者應該將封包視為即將到來對待。

#### Decoder#destroy()

取消分配給解碼器實例的資源。函式應該在解碼中斷等事件發生時呼叫。以防止發生記憶體洩露。

### Parser#types

封包類型的鍵值 (type keys) 的陣列。

### Packet

每個封包都代表一個 vanilla `Object` (譯註：[plain vanilla][0])，且含有一個 `nsp` 鍵值表示它屬於哪一個命名空間 (namespace) (參考 "Multiplexing" 多路傳輸)，
與一個 `type` 鍵值，它可以是下列幾種類型之一：

- `Packet#CONNECT` (`0`)
- `Packet#DISCONNECT` (`1`)
- `Packet#EVENT` (`2`)
- `Packet#ACK` (`3`)
- `Packet#ERROR` (`4`)
- `Packet#BINARY_EVENT` (`5`)
- `Packet#BINARY_ACK` (`6`)

#### EVENT

- `data` (`Array`) 一個參數 (arguments) 列表，第一個參數是事件名稱。參數可以包含任何可被 JSON 解碼的型別，
    包含任意數量的物件與陣列。
- `id` (`Number`) 如果 `id` 的識別符 (identifier) 存在。則表示服務端希望對該事件的接收進行確認。

#### BINARY_EVENT

- `data` (`Array`) 參考 `EVENT` `data`。除此之外，任何參數都可能包含 non-JSON 的任意二進位數據。
  對於編碼，二進位數據被認為是 Buffer, ArrayBuffer, Blob, 或 File。解碼時，所有的二進位數據在服務端都是 Buffer；
  在比較新的客戶端上，二進位數據是 ArrayBuffer。在舊的不支援二進位的瀏覽器上，每個二進位數據項目都會被像下面的物件所取代：
  `{base64: true, data: <base64_bin_encoding>}`。當開始解碼一個 `BINARY_EVENT` 或 `ACK` 封包時，
  所有的二進位資料項目都會被佔位符取代，並透過額外的 `Decoder#add` 函式呼叫來填充。
- `id` (`Number`) 參考 `EVENT` `id`。

#### ACK

- `data` (`Array`) 參考 `EVENT` `data`。 如上面的 `EVENT` 類型編碼為字串。
  應該用在不包含二進位資料的 ACK 回應時。
- `id` (`Number`) 參考 `EVENT` `id`。

#### BINARY_ACK

- `data` (`Array`) see `ACK` `data`. 用在包含二進位資料的 ACK 回應時；
  編碼請參考同上面的 `BINARY_EVENT` 文件。
- `id` (`Number`) see `EVENT` `id`.

#### ERROR

- `data` (`Mixed`) 錯誤資料。

## Transport

socket.io 協議可以透過各種不同的傳輸來發送。
[socket.io-client](http://github.com/learnboost/socket.io-client)
是基於 [engine.io](http://github.com/learnboost/engine.io) 之上的瀏覽器與 Node.JS 的協議實現。

[socket.io](http://github.com/learnboost/socket.io) 是基於
[engine.io](http://github.com/learnboost/engine.io) 之上的服務端的協議實現。

## Multiplexing

Socket.IO 具有內建的多路傳輸支援。表示每個封包都屬於某個 `命名空間`，透過路徑 (path) 字串來識別 (像是 `/this`)。
在 `Packet` 物件中對應的鍵值是 `nsp`。

當 socket.io 的傳輸連線建立時。假設會嘗試連結到 `/` 命名空間 (亦即，在服務端的行為就如客戶端已向 `/` 命名空間發送一個 `CONNECT` 封包)。

為了在同一個傳輸下支援多個 sockets 的多路傳輸，客戶端可以將額外的 `CONNECT` 封包發送到任意命名空間的 URIs (例如：`/another`)。

當服務端回應一個 `CONNECT` 封包到對應的命名空間，這個多路傳輸的 socket 應該被認為是已連線的。

或者，服務端可以使用一個 `ERROR` 封包來表示多路傳輸 socket 的連線錯誤，例如認證錯誤。
錯誤的內容會根據每個錯誤的不同而變化，並且可以由用戶自行定義。

服務端在特定的 `nsp` 收到到一個 `CONNECT` 封包後，客戶端就可以開始發送並接收 `EVENT` 封包。
如果任何一方收到一個包含 `id` 欄位的 `EVENT` 封包，則預期要透過 `ACK` 封包來回應確認。

## License

MIT

[0]: https://en.wikipedia.org/wiki/Plain_vanilla
