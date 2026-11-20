# HQ-LISP 样例

需 `-DPCB_ENABLE_LISP=ON` 构建。在 Console / Telnet / 底部 **LISP** Tab 中：

```text
lisp-load Samples/Scripts/Lisp/01_hello.lsp
lisp-eval (+ 1 2)
mode lisp
```

其它语言短加载（`js-load` / `python-load` / `go-load`）见 [../README.md](../README.md)。

| 文件 | 说明 |
|------|------|
| `01_hello.lsp` | 纯 Scheme 算术 |
| `02_define.lsp` | `define` / `lambda` / `let` |
| `03_cmdlet_mode.lsp` | `(cmdlet "mode")` 桥接 |
| `04_cmdlet_calc.lsp` | `(cmdlet "calc …")` 调用近程表达式 |
| `05_begin.lsp` | 多形式 `begin` 与打印式返回 |
| `06_open_and_read.lsp` | **打开** `Samples/Boards` 样板板并读取 workspace/层/选择集 |
| `07_read_selection.lsp` | **交互读取**：画布选中对象后打印 `(entity-get id)` |
| `08_action_line.lsp` | **交互动作**：两点 click 后 `(action-input 'command "enter")` 提交（勿先 cancel） |
| `09_action_route.lsp` | **走线**：`(open-and-wait …)` → `route` → `(action-input 'move-line/'click/'dbclick)` → cancel → `zoomall` |

## 打开 PCB 与读取（推荐流程）

1. 打开样板（`(pcb-resolve …)` 会按 load 白名单解析到仓库内真实 `.hqpcbx`，避免 `.app` cwd 下的 0 字节占位）：

```text
lisp-load Samples/Scripts/Lisp/06_open_and_read.lsp
```

可选覆盖板路径：

```text
lisp-eval (define *board* "/ABS/PCB_V5/Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
lisp-load Samples/Scripts/Lisp/06_open_and_read.lsp
```

2. 在画布上点选 / 框选若干对象，再读选择集与对象摘要：

```text
lisp-load Samples/Scripts/Lisp/07_read_selection.lsp
```

3. （可选）脚本驱动画线工具两点：

```text
lisp-load Samples/Scripts/Lisp/08_action_line.lsp
```

4. （可选）打开样板板并演示 Route 走线（`(action-input …)` + `(sleep-ms …)`）：

```text
lisp-load Samples/Scripts/Lisp/09_action_route.lsp
```

路径须落在 Session load 白名单（工程根、仓库根、`Scripts/`、`Samples/Scripts/Lisp`、应用目录等）。`(pcb-resolve)` / `lisp-load` 相对路径**优先白名单根且优先非空文件**，再回退 cwd，因此在 `.app` 内启动时仍可写：

```text
lisp-load Samples/Scripts/Lisp/01_hello.lsp
lisp-eval (pcb-resolve "Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
```

语言参考见 [`docs/lisp/language-reference.md`](../../../docs/lisp/language-reference.md)。
