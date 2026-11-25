// Spike: wasi-http inbound via wasmtime serve (host binds port).
// go-load Samples/Scripts/Go/wasip2_http_hello
package main

import (
	"net/http"

	_ "github.com/ydnar/wasi-http-go/wasihttp" // enable wasi:http/proxy
)

func init() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.Header().Set("X-PCB", "wasip2-http")
		_, _ = w.Write([]byte("hello wasip2-http\n"))
	})
}

func main() {}
