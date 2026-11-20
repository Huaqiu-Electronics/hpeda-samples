# Boards — 简易 V5 样板（`.hqpcbx` / `.hqpcb`）

覆盖基本与进阶 PCB 元素的小样板，便于打开验证、导入回归与教学演示。  
**SDK / 脚本示例默认使用 `hqpcbx/*.hqpcbx`（文本工程）。**

## 目录

| 路径 | 说明 |
|------|------|
| `src/*.kicad_pcb` | 手写 KiCad 源（权威可编辑稿） |
| `hqpcbx/*.hqpcbx` | 文本工程（SDK 样例默认；`convert_to_hqpcb.sh --hqpcbx-only`） |
| `hqpcb/*.hqpcb` | SQLite 工程（可选，`convert_to_hqpcb.sh`） |
| `convert_to_hqpcb.sh` | 批量 `HQPCB_CLI convert`（`--hqpcbx` / `--hqpcbx-only`） |

## 样板一览

### 基础

| 文件 | 覆盖元素 |
|------|----------|
| `01_tracks_vias` | 板框、网络、直线走线、过孔、丝印文字 |
| `02_components_pads` | SMD/插件封装、焊盘、位号/值、短走线 |
| `03_zones_graphics` | 铺铜、丝印线/圆/弧/多边形、文字 |
| `04_all_basics` | 上述元素合一的综合小板 |

### 进阶

| 文件 | 覆盖元素 |
|------|----------|
| `05_arc_tracks_vias` | 圆弧走线、4 层板、microvia、贯通过孔 |
| `06_keepout_netclass` | 禁布区 keepout、net_class（含差分）、铺铜 |
| `07_custom_pads_curves` | oval/roundrect/custom 焊盘、安装孔、贝塞尔曲线、填充矩形/圆 |
| `08_blind_bottom` | 盲孔、顶/底面器件、镜像丝印 |
| `09_slots_thermals` | 椭圆槽孔、NPTH、zone_connect/热焊盘、铺铜 |
| `10_outline_arcs` | Edge.Cuts 圆弧板框、丝印弧/圆、铺铜 |
| `11_diffpair_route` | USB 差分平行/圆弧走线、net_class、连接器+IC |

## 重新转换

```bash
./Samples/Boards/convert_to_hqpcb.sh --hqpcbx-only   # SDK 样例用（推荐）
./Samples/Boards/convert_to_hqpcb.sh --hqpcbx        # 同时写出 .hqpcb + .hqpcbx
./Samples/Boards/convert_to_hqpcb.sh                 # 仅 .hqpcb
```

第三方直出文本工程也可单文件：

```bash
HQPCB_CLI convert Samples/Boards/src/01_tracks_vias.kicad_pcb Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx
```

## 打开

```bash
project.open /abs/path/to/Samples/Boards/hqpcbx/11_diffpair_route.hqpcbx
project.open /abs/path/to/Samples/Boards/hqpcb/11_diffpair_route.hqpcb
```

亦可直接 `project.open` 对应的 `.kicad_pcb`（走 KiCad 导入插件）。
