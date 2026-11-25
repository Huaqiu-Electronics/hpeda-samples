# wasip2_wit_bridge — M3 WIT 尖兵

Guest 经 **`hqpcb:host/op`** WIT import 调宿主；`wac plug` 接入 **文件桥 adapter**，现有 `PCB_HOST_DIR` 泵送仍可用（无需嵌入 Wasmtime linker）。

```text
guest (witbridge)  --import op-->  adapter (export op → req/resp)  --files-->  pump / GoScriptHost
```

## 依赖

- 捆绑 TinyGo / wasm-tools / Wasmtime（HQ PCB Resources）
- `wac`（`cargo install wac-cli`）
- `wit-bindgen-go`（仅再生成绑定时需要）

## 一键

```bash
./scripts/build_and_run.sh
# 期望 stderr/stdout：host<log>: wasip2-wit-bridge-ok
```

## 手工

```bash
tinygo build -tags witbridge -target=./wasip2-hqpcb.json -o guest.wasm .
(cd adapter && tinygo build -target=./wasip2-hqpcb-adapter.json -o ../adapter.wasm .)
wac plug --plug adapter.wasm guest.wasm -o composed.wasm
# + pump_host.py + wasmtime run --wasm component-model --dir … composed.wasm
```

## 与产品双轨

| 轨 | Guest 构建 | 宿主侧 |
|----|------------|--------|
| **file**（缺省） | 无 `-tags witbridge` | `GoScriptHost` 泵 req/resp |
| **wit**（本样例） | `-tags witbridge` + `wasip2-hqpcb.json` | HQ PCB：`GoScriptWitBridge` 自动 `wac plug` + `Resources/goscript/host-adapter.wasm` |

`PCB_HOST_BRIDGE=auto|wit|file`（缺省 auto）：有 `hqpcb:host/op` 导入才 compose。Guest 侧以 **build tag** 为准。