// Usage (spike): tinygo build -o out.wasm -target=wasip2 .
// Run: wasmtime run --wasm component-model out.wasm
// Platform migration tip of spear for wasip1 → wasip2.
// go-load Samples/Scripts/Go/wasip2_hello
package main

func main() {
	println("hello wasip2")
}
