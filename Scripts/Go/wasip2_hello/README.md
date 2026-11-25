# wasip2 tip-of-spear

Minimal Guest with **no** hqeda dependency — proves TinyGo `wasip2` + `wasm-tools` + Wasmtime component model.

```bash
export TINYGOROOT=…/tinygo-0.42.0
export WASMOPT=…/wasm-opt
export PATH=…/wasm-tools-1.263.0-aarch64-macos:…/go/bin:$PATH

tinygo build -o out.wasm -target=wasip2 .
wasmtime run --wasm component-model out.wasm
# → hello wasip2
```

Platform switch: set `PCB_GOSCRIPT_WASI_TARGET=wasip2` in HQ PCB (see `Wasip2PlatformMigration.md`).
