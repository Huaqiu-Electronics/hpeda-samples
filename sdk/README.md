# SDK 访问示例（Python / JavaScript / Go）

通过 Arrow Flight IPC 访问 HQPCB，**读写** `Samples/Boards/hqpcbx` 下的简易 V5 样板。  
产品入口统一为 **ClientFactory**；推荐一键建连：Go `hqeda.NewConnection(gui)` / Python `new_connection(gui)` / JS `createConnection(gui)`。  
端点解析在 SDK：`hqeda.ResolveEndpoint` / `resolve_endpoint` / `resolveEndpoint`；样例薄封装见各语言 `helper`。  
写路径文档：[`sdk/docs/Flight-Write-API.md`](../../sdk/docs/Flight-Write-API.md)。

| 语言 | 目录 | 运行 |
|------|------|------|
| Python | [`python/`](./python/) | `./python/run 11_design_write.py` |
| JavaScript | [`javascript/`](./javascript/) | `./javascript/run 11_design_write.js` |
| Go | [`go/`](./go/) | `./go/run 11_design_write` |

## 样板板 ↔ 示例

| 示例 | 默认 `.hqpcbx` | 读写要点 |
|------|---------------|----------|
| `01_hello_ping` | （无板） | 连接 / ping / caps |
| `02_methods_list` | （无板） | methods.list |
| `03_config` | （无板） | config.get / set **写** |
| `04_workspace_rw` | `01_tracks_vias` | ws.open + design 租约 **读/写** |
| `05_tracks_length` | `05_arc_tracks_vias` | tracks / 线长 **读** |
| `06_nets_vias` | `01_tracks_vias` | nets / vias **读** |
| `07_footprints_pads` | `02_components_pads` | footprints / pads / layers **读** |
| `08_zones_keepout` | `06_keepout_netclass` | zones / drawings / bbox **读** |
| `09_netclasses` | `11_diffpair_route` | design_settings / net_classes **读** |
| `10_objects_query` | `04_all_basics` | DoGet objects.list / query.table **读** |
| `11_design_write` | `01_tracks_vias` | `WriteLease` 批量 **写** + 错 token 拒写 |
| `12_workspace_write` | `01`+`02` | ws.open / switch / close **写** |

可用其它板替换默认路径，例如：

```bash
./python/run 07_footprints_pads.py headless ../../Boards/hqpcbx/08_blind_bottom.hqpcbx
```

## 前置

1. 启动 Flight 服务（逻辑管道名，默认 `hqpcb-svc`）：

```bash
# 仓库根目录
./build/cmake/Runtime/IPC/pcb_IPC_skel_serve --pipe hqpcb-svc --role service
# 或已声明 workspace+design 的 GUI：hqpcb-gui
```

2. SDK 依赖：

- Python：`sdk/python/.venv` + `requirements-IPC.txt`
- JS：`sdk/javascript` 下 `npm install`
- Go：本机 `go`；`Samples/sdk/go/go.mod` 已 `replace` 到仓库内 `sdk/go/hqeda`

## 端点

与旧 `sdk/*/samples` 相同：`headless` / `gui` / `hqpcb-svc` / `hqpcb-gui` / `PCB_IPC_ENDPOINT`。
