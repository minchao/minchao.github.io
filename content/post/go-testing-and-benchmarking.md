# Go 測試與性能

## go test tool

[go test](https://golang.org/cmd/go/#hdr-Test_packages) 指令是語言內建的測試工具，用來執行在指定的 package 內，所有檔案名稱以 `_test.go` 為後綴的測試程式。

## 測試函數

### Basic test

基礎的單元測試，使用一組初始化資料和預期結果來進行測試。

```go
// 示範如何撰寫基礎的單元測試
package listing01

import (
	"net/http"
	"testing"
)

const checkMark = "\u2713"
const ballotX = "\u2717"

// TestDownload 驗證 http get 函數下載的內容
func TestDownload(t *testing.T) {
	url := "http://www.goinggo.net/feeds/posts/default?alt=rss"
	statusCode := 200

	t.Log("Given the need to test downloading content.")
	{
		t.Logf("\tWhen checking \"%s\" for status code \"%d\"",
			url, statusCode)
		{
			resp, err := http.Get(url)
			if err != nil {
				t.Fatal("\t\tShould be able to make the Get call.",
					ballotX, err)
			}
			t.Log("\t\tShould be able to make the Get call.",
				checkMark)

			defer resp.Body.Close()

			if resp.StatusCode == statusCode {
				t.Logf("\t\tShould receive a \"%d\" status. %v",
					statusCode, checkMark)
			} else {
				t.Errorf("\t\tShould receive a \"%d\" status. %v %v",
					statusCode, ballotX, resp.StatusCode)
			}
		}
	}
}
```

- 函數必須是公開的，且以 `Test` 為前綴
- 函數的參數必須有 `testing.T` 類型的指標，用來報告測試的輸出與狀態
- 測試的輸出是程式說明的一部分，建議可以按照 [Given-When-Then（GWT）](https://martinfowler.com/bliki/GivenWhenThen.html) 格式來撰寫

執行測試

```console
$ go test -v
=== RUN   TestDownload
--- PASS: TestDownload (3.96s)
    listing01_test.go:17: Given the need to test downloading content.
    listing01_test.go:19:       When checking "http://www.goinggo.net/feeds/posts/default?alt=rss" for status code "200"
    listing01_test.go:27:               Should be able to make the Get call. ✓
    listing01_test.go:33:               Should receive a "200" status. ✓
PASS
ok      _/srv/workspace/github.com/goinaction/code/chapter9/listing01   3.991s
```

- go test 會自動執行文件名稱後綴為 `_test.go` 的測試
- 執行時加上 `-v` 參數，顯示詳細訊息

> Go 沒有內建 assert 函數，建議搭配第三方的 [testify](https://github.com/stretchr/testify) 使用
>
> A toolkit with common assertions and mocks that plays nicely with the standard library

### Table test

使用多組不同的初始化資料和期望結果，並依序迭代來執行測試。

```go
// Sample test to show how to write a basic unit table test.
package listing08

import (
	"net/http"
	"testing"
)

const checkMark = "\u2713"
const ballotX = "\u2717"

// TestDownload validates the http Get function can download
// content and handles different status conditions properly.
func TestDownload(t *testing.T) {
	var urls = []struct {
		url        string
		statusCode int
	}{
		{
			"http://www.goinggo.net/feeds/posts/default?alt=rss",
			http.StatusOK,
		},
		{
			"http://rss.cnn.com/rss/cnn_topstbadurl.rss",
			http.StatusNotFound,
		},
	}

	t.Log("Given the need to test downloading different content.")
	{
		for _, u := range urls {
			t.Logf("\tWhen checking \"%s\" for status code \"%d\"",
				u.url, u.statusCode)
			{
				resp, err := http.Get(u.url)
				if err != nil {
					t.Fatal("\t\tShould be able to Get the url.",
						ballotX, err)
				}
				t.Log("\t\tShould be able to Get the url.",
					checkMark)

				defer resp.Body.Close()

				if resp.StatusCode == u.statusCode {
					t.Logf("\t\tShould have a \"%d\" status. %v",
						u.statusCode, checkMark)
				} else {
					t.Errorf("\t\tShould have a \"%d\" status. %v %v",
						u.statusCode, ballotX, resp.StatusCode)
				}
			}
		}
	}
}
```

- 可以輕易加入新的測試條件，而不需要新增測試函數

執行測試

```console
$ go test -v
=== RUN   TestDownload
--- PASS: TestDownload (3.22s)
    listing08_test.go:29: Given the need to test downloading different content.
    listing08_test.go:32:       When checking "http://www.goinggo.net/feeds/posts/default?alt=rss" for status code "200"
    listing08_test.go:40:               Should be able to Get the url. ✓
    listing08_test.go:46:               Should have a "200" status. ✓
    listing08_test.go:32:       When checking "http://rss.cnn.com/rss/cnn_topstbadurl.rss" for status code "404"
    listing08_test.go:40:               Should be able to Get the url. ✓
    listing08_test.go:46:               Should have a "404" status. ✓
PASS
ok      _/srv/workspace/github.com/goinaction/code/chapter9/listing08   3.252s
```

### Mock HTTP server

如何在沒有網路連結的情況下，執行單元測試？標準庫提供了 [httptest](https://golang.org/pkg/net/http/httptest/#Server) package，用來 mocking 基於 HTTP 的網路呼叫。

```go
// Sample test to show how to mock an HTTP GET call internally.
// Differs slightly from the book to show more.
package listing12

import (
	"encoding/xml"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

const checkMark = "\u2713"
const ballotX = "\u2717"

// feed is mocking the XML document we except to receive.
var feed = `<?xml version="1.0" encoding="UTF-8"?>
<rss>
<channel>
    <title>Going Go Programming</title>
    <description>Golang : https://github.com/goinggo</description>
    <link>http://www.goinggo.net/</link>
    <item>
        <pubDate>Sun, 15 Mar 2015 15:04:00 +0000</pubDate>
        <title>Object Oriented Programming Mechanics</title>
        <description>Go is an object oriented language.</description>
        <link>http://www.goinggo.net/2015/03/object-oriented</link>
    </item>
</channel>
</rss>`

// mockServer returns a pointer to a server to handle the get call.
func mockServer() *httptest.Server {
	f := func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Header().Set("Content-Type", "application/xml")
		fmt.Fprintln(w, feed)
	}

	return httptest.NewServer(http.HandlerFunc(f))
}

// TestDownload validates the http Get function can download content
// and the content can be unmarshaled and clean.
func TestDownload(t *testing.T) {
	statusCode := http.StatusOK

	server := mockServer()
	defer server.Close()

	t.Log("Given the need to test downloading content.")
	{
		t.Logf("\tWhen checking \"%s\" for status code \"%d\"",
			server.URL, statusCode)
		{
			resp, err := http.Get(server.URL)
			if err != nil {
				t.Fatal("\t\tShould be able to make the Get call.",
					ballotX, err)
			}
			t.Log("\t\tShould be able to make the Get call.",
				checkMark)

			defer resp.Body.Close()

			if resp.StatusCode != statusCode {
				t.Fatalf("\t\tShould receive a \"%d\" status. %v %v",
					statusCode, ballotX, resp.StatusCode)
			}
			t.Logf("\t\tShould receive a \"%d\" status. %v",
				statusCode, checkMark)

			var d Document
			if err := xml.NewDecoder(resp.Body).Decode(&d); err != nil {
				t.Fatal("\t\tShould be able to unmarshal the response.",
					ballotX, err)
			}
			t.Log("\t\tShould be able to unmarshal the response.",
				checkMark)

			if len(d.Channel.Items) == 1 {
				t.Log("\t\tShould have \"1\" item in the feed.",
					checkMark)
			} else {
				t.Error("\t\tShould have \"1\" item in the feed.",
					ballotX, len(d.Channel.Items))
			}
		}
	}
}

// Item defines the fields associated with the item tag in
// the buoy RSS document.
type Item struct {
	XMLName     xml.Name `xml:"item"`
	Title       string   `xml:"title"`
	Description string   `xml:"description"`
	Link        string   `xml:"link"`
}

// Channel defines the fields associated with the channel tag in
// the buoy RSS document.
type Channel struct {
	XMLName     xml.Name `xml:"channel"`
	Title       string   `xml:"title"`
	Description string   `xml:"description"`
	Link        string   `xml:"link"`
	PubDate     string   `xml:"pubDate"`
	Items       []Item   `xml:"item"`
}

// Document defines the fields associated with the buoy RSS document.
type Document struct {
	XMLName xml.Name `xml:"rss"`
	Channel Channel  `xml:"channel"`
	URI     string
}
```

## Example 函數

- 作為文件，展示 package 該如何被使用，例如 [json.NewDecoder](https://golang.org/pkg/encoding/json/#example_Decoder)
- 同時也可以作為測試的一部分

[json.NewDecoder 原始碼](https://github.com/golang/go/blob/ad6c691542e2d842c90e2f7870021d16ffa71878/src/encoding/json/example_test.go#L56-L84)

```go
// This example uses a Decoder to decode a stream of distinct JSON values.
func ExampleDecoder() {
	const jsonStream = `
	{"Name": "Ed", "Text": "Knock knock."}
	{"Name": "Sam", "Text": "Who's there?"}
	{"Name": "Ed", "Text": "Go fmt."}
	{"Name": "Sam", "Text": "Go fmt who?"}
	{"Name": "Ed", "Text": "Go fmt yourself!"}
`
	type Message struct {
		Name, Text string
	}
	dec := json.NewDecoder(strings.NewReader(jsonStream))
	for {
		var m Message
		if err := dec.Decode(&m); err == io.EOF {
			break
		} else if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%s: %s\n", m.Name, m.Text)
	}
	// Output:
	// Ed: Knock knock.
	// Sam: Who's there?
	// Ed: Go fmt.
	// Sam: Go fmt who?
	// Ed: Go fmt yourself!
}
```

- 函數必須是公開的，且以 `Example` 為前綴
- Example 函數的名稱必須基於已存在的公開函數，godoc 會將 example 關聯到對應的函數或 package，成為其文件的一部分
- 執行測試時 example 也會被執行。注意 L23 的 `Output:` 註解，它標記函數預期的輸出，並在測試時自動比對，若不匹配則測試失敗

測試失敗範例：

```console
$ go test -v -run="ExampleSendJSON"
=== RUN   ExampleSendJSON
--- FAIL: ExampleSendJSON (0.00s)
got:
{Bill bill@ardanstudios.com}
want:
{Lisa lisa@ardanstudios.com}
FAIL
exit status 1
FAIL    github.com/goinaction/code/chapter9/listing17/handlers  0.028s
```

> 使用 `-run` 可以指定測試函數，支援正則表達式

## Benchmark 函數

測試程式性能的方法。例如，用來比較不同方案間的性能，哪一個更好。

```go
// Sample benchmarks to test which function is better for converting
// an integer into a string. First using the fmt.Sprintf function,
// then the strconv.FormatInt function and then strconv.Itoa.
package listing05_test

import (
	"fmt"
	"strconv"
	"testing"
)

// BenchmarkSprintf provides performance numbers for the
// fmt.Sprintf function.
func BenchmarkSprintf(b *testing.B) {
	number := 10

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		fmt.Sprintf("%d", number)
	}
}

// BenchmarkFormat provides performance numbers for the
// strconv.FormatInt function.
func BenchmarkFormat(b *testing.B) {
	number := int64(10)

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		strconv.FormatInt(number, 10)
	}
}

// BenchmarkItoa provides performance numbers for the
// strconv.Itoa function.
func BenchmarkItoa(b *testing.B) {
	number := 10

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		strconv.Itoa(number)
	}
}
```

- 函數必須是公開的，且以 `Benchmark` 為前綴
- 函數參數必須有 `testing.B` 類型的指標
- 為了準確測試性能，使用 for 迴圈反覆執行被測方法，迴圈的 `b.N` 會自動決定需要執行的次數
- `b.ResetTimer()` 重置計時器，保證測試方法執行前的初始化，不會影響計時器的結果

執行單個 benchmark 測試

```bash
$ go test -v -run="none" -bench="BenchmarkSprintf"
goos: darwin
goarch: amd64
pkg: github.com/goinaction/code/chapter9/listing28
BenchmarkSprintf-4      12989098                88.2 ns/op
PASS
ok      github.com/goinaction/code/chapter9/listing28   1.257s
```

- 參數 `-bench`，指定想執行的 benchmark 測試
- 參數 `-run="none"`，保證沒有其它的單元測試會被執行

執行所有測試

```console
go test -v -run="none" -bench=.
goos: darwin
goarch: amd64
pkg: github.com/goinaction/code/chapter9/listing28
BenchmarkSprintf-4      13231104                86.0 ns/op
BenchmarkFormat-4       439194771                2.70 ns/op
BenchmarkItoa-4         437812339                2.76 ns/op
PASS
ok      github.com/goinaction/code/chapter9/listing28   4.192s
```

觀察記憶體分配大小及次數

```console
$ go test -v -run="none" -bench=. -benchmem
goos: darwin
goarch: amd64
pkg: github.com/goinaction/code/chapter9/listing28
BenchmarkSprintf-4      12172134                91.4 ns/op            16 B/op          2 allocs/op
BenchmarkFormat-4       390050862                2.87 ns/op            0 B/op          0 allocs/op
BenchmarkItoa-4         398680538                2.89 ns/op            0 B/op          0 allocs/op
PASS
ok      github.com/goinaction/code/chapter9/listing28   4.120s
```

- `B/op`，每次操作分配的記憶體 bytes 數
- `allocs/op`，每次操作在 heap 上分配記憶體的次數

## Data race detector

Data races 是並行系統中最常見也最年除錯的錯誤類型之一。當兩個 goroutine 並行訪問同一變數且至少其中之一是寫操作時，就會發生數據競用。

使用 `-race` 參數自動偵測 data race

```console
$ go test -race mypkg    // test the package
$ go run -race mysrc.go  // compile and run the program
$ go build -race mycmd   // build the command
$ go install -race mypkg // install the package
```

> 更多資訊請參考：
>
> - [Data Race Detector](https://golang.org/doc/articles/race_detector.html)
> - [Introducing the Go Race Detector](https://blog.golang.org/race-detector)

## 測試覆蓋率

執行測試並紀錄覆蓋率

```console
$ go test -coverprofile=coverate.out
```

顯示測試覆蓋率

```console
$ go tool cover -html=coverate.out
PASS
coverage: 42.9% of statements
ok      size    0.026s
```

![](https://i.imgur.com/I72fJFs.png)

> 執行後將開啟一瀏覽器視窗，綠色表示已覆蓋，紅色表示未覆蓋，而灰色表示未經檢測

> 更多資訊請參考 [The cover story](https://blog.golang.org/cover)

### Heat maps

go test 指令還支援 `-covermode` 參數指定覆蓋率計算模式：

- set: did each statement run? (default)
- count: how many times did each statement run?
- atomic: like count, but counts precisely in parallel programs

## Profiling

透過抽樣分析程式的執行效能。

Golang 支援多種性能分析方式，每一種關注不同的面向，例如：

- `-cpuprofile`，識別最耗費 CPU 時間的函數
- `-memprofile`，識別最耗費記憶體的函數
- `-blockprofile`，紀錄阻塞 goroutine 最久的操作，如系統呼叫、channel 發送與接收，還有 acquisitions of locks 等

收集並顯示 CPU profile

```console
$ go test -run=none -bench=ClientServerParallelTLS64 \
    -cpuprofile=cpu.log net/http
PASS
BenchmarkClientServerParallelTLS64-8  1000
   3141325 ns/op  143010 B/op  1747 allocs/op
ok      net/http       3.395s
```

```console
$ go tool pprof -text -nodecount=10 ./http.test cpu.log
2570ms of 3590ms total (71.59%)
Dropped 129 nodes (cum <= 17.95ms)
Showing top 10 nodes out of 166 (cum >= 60ms)
    flat  flat%   sum%     cum   cum%
  1730ms 48.19% 48.19%  1750ms 48.75%  crypto/elliptic.p256ReduceDegree
   230ms  6.41% 54.60%   250ms  6.96%  crypto/elliptic.p256Diff
   120ms  3.34% 57.94%   120ms  3.34%  math/big.addMulVVW
   110ms  3.06% 61.00%   110ms  3.06%  syscall.Syscall
    90ms  2.51% 63.51%  1130ms 31.48%  crypto/elliptic.p256Square
    70ms  1.95% 65.46%   120ms  3.34%  runtime.scanobject
    60ms  1.67% 67.13%   830ms 23.12%  crypto/elliptic.p256Mul
    60ms  1.67% 68.80%   190ms  5.29%  math/big.nat.montgomery
    50ms  1.39% 70.19%    50ms  1.39%  crypto/elliptic.p256ReduceCarry
    50ms  1.39% 71.59%    60ms  1.67%  crypto/elliptic.p256Sum
```

- 參數 `-text` 指定輸出格式，這裡每行代表一個函數
- 參數 `-nodecount=10` 限制輸出結果的數量為 10 個

> 如果需要使用 pprof 的圖形功能，請安裝 [GraphViz](http://www.graphviz.org) 工具

> 更多資訊請參考 [Profiling Go Programs](https://blog.golang.org/profiling-go-programs)

## 參考資料

書籍

- [Go in Action](https://www.oreilly.com/library/view/go-in-action/9781617291784/) 9. Testing and benchmarking
  - https://github.com/goinaction/code/tree/master/chapter9
- [The Go Programming Language](https://learning.oreilly.com/library/view/the-go-programming/9780134190570/) 11. Testing

其它參考資料

- [Testable Examples in Go](https://blog.golang.org/examples)
- [Using Subtests and Sub-benchmarks](https://blog.golang.org/subtests)
