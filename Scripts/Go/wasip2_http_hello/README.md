# wasip2 HTTP tip-of-spear

Inbound HTTP via **wasi-http** + `wasmtime serve`（宿主绑端口，Guest 只实现 handler）。

## go-load / script.go.run

宿主检测到目录旁 `wasip2-http.json`（或源引用 wasi-http-go）后：

1. `tinygo build -target=./wasip2-http.json`
2. `GoWasiHttpServe` → `wasmtime serve -Scli -Shttp --addr 127.0.0.1:0`（非 detached；同 `id` 替换）
3. 回显 `Serving HTTP on http://127.0.0.1:<port>/ (id=…)`

```text
go-load Samples/Scripts/Go/wasip2_http_hello
# → Serving HTTP on http://127.0.0.1:xxxxx/ (id=default)
# curl 该地址 ⇒ hello wasip2-http

script.go.run path=Samples/Scripts/Go/wasip2_http_hello id=hello2
script.go.http.list
script.go.http.stop default
script.go.http.stop all
```

若曾误用旧 wasip1 缓存：`script.go.cache.clear` 后再 go-load。

## 手工构建（不经宿主）

```bash
# 工具链：捆绑 TinyGo / Go / Binaryen / wasm-tools（无系统 go 亦可）
export TINYGOROOT=…/tinygo-0.42.0
export WASMOPT=…/wasm-opt
export PATH=…/wasm-tools:…/go/bin:$TINYGOROOT/bin:$PATH
export GOROOT=…/go  GOTOOLCHAIN=local
export GOPROXY=https://goproxy.cn,direct

go mod download
tinygo build -o out.wasm -target=./wasip2-http.json .

wasmtime serve -Scli -Shttp --addr 127.0.0.1:18765 out.wasm
# → curl http://127.0.0.1:18765/  ⇒  hello wasip2-http
```

- `wasip2-http.json`：继承 TinyGo `wasip2`，`wit-world=go:http/proxy`
- `wit/proxy.wit`：从 wasi-http-go 钉选拷贝
- 依赖：`github.com/ydnar/wasi-http-go`

见 `Wasip2PlatformMigration.md` M0 / M4。
