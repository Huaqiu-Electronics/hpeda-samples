# wasip2_wit_bridge — M3 WIT 尖兵

Guest 经 **`hqpcb:host/op`** WIT import 调宿主。

优先用 **`pcb-wit-run`**（真 link）；回落 `wac plug` + 文件桥 adapter。

```text
guest (witbridge)  --import op-->  pcb-wit-run / adapter  --files-->  pump / GoScriptHost
```

## 依赖

- 捆绑 TinyGo / wasm-tools / Wasmtime（HQ PCB Resources）
- `pcb-wit-run`（`Interop/PcbWitRun`，CMake `PCB_BUILD_PCB_WIT_RUN`）或 `wac`（`cargo install wac-cli`）

## 一键（adapter 组合）

```bash
./scripts/build_and_run.sh
# 期望：host<log>: wasip2-wit-bridge-ok
```

## pcb-wit-run（推荐）

```bash
tinygo build -tags witbridge -target=./wasip2-hqpcb.json -o guest.wasm .
pcb-wit-run --dir "$HOST" --env "PCB_HOST_DIR=$HOST" guest.wasm
```

## 与产品双轨

| 轨 | Guest 构建 | 宿主侧 |
|----|------------|--------|
| **file**（缺省） | 无 `-tags witbridge` | `GoScriptHost` 泵 req/resp |
| **wit**（本样例） | `-tags witbridge` + `wasip2-hqpcb.json` | 优先 `pcb-wit-run`；回落 `wac plug` |

`PCB_HOST_BRIDGE=auto|wit|file`（缺省 auto）。Guest 侧以 **build tag** 为准。
