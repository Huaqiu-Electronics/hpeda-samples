# wasip2_wit_bridge — M3 WIT 尖兵

Guest 经 **`hqpcb:host/op`** WIT import 调宿主。

桌面 witbridge **强制** [`pcb-wit-run`](../../../../Interop/PcbWitRun/)（`PCB_HOST_RPC` + `PCB_HOST_TO_GUEST`）。产品路径不再 wac/文件桥回落。

```text
guest (witbridge)  --WIT op-->  pcb-wit-run  --RPC-->  rpc_host / GoScriptHost
                   <--host-pull--  PCB_HOST_TO_GUEST
```

## 依赖

- 捆绑 TinyGo / wasm-tools（HQ PCB Resources）
- `pcb-wit-run`（`Interop/PcbWitRun`，CMake `PCB_BUILD_PCB_WIT_RUN`）

## 推荐：pcb-wit-run E2E

```bash
./scripts/run_pcb_wit_run.sh
# 期望：rpc<log>: wasip2-wit-bridge-ok
#       req_files=0 inbox_files=0
```

## 可选：adapter + wac（教学 / 非产品路径）

```bash
./scripts/build_and_run.sh
# 期望：host<log>: wasip2-wit-bridge-ok
```

## 与产品双轨

| 轨 | Guest 构建 | 宿主侧 |
|----|------------|--------|
| **wit**（本样例 / 预编译插件） | `-tags witbridge` + `wasip2-hqpcb.json` | **必须** `pcb-wit-run` + RPC + HostToGuest |
| **file** | 无 `-tags witbridge` / wasip1 | `GoScriptHost` 泵 req/resp + inbox |

`PCB_HOST_BRIDGE=auto|wit|file`（缺省 auto）。Guest 侧以 **build tag** 为准。
