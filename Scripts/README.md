# Samples/Scripts

控制台 / Telnet 一键加载脚本（对齐 `lisp-load`）：

```text
lisp-load   Samples/Scripts/Lisp/01_hello.lsp
js-load     Samples/Scripts/Js/01_hello.js
python-load Samples/Scripts/Python/01_hello.py
go-load     Samples/Scripts/Go/01_hello
```

走线演示（对齐 `09_action_route.lsp`）：

```text
lisp-load   Samples/Scripts/Lisp/09_action_route.lsp
js-load     Samples/Scripts/Js/09_action_route.js
python-load Samples/Scripts/Python/09_action_route.py
go-load     Samples/Scripts/Go/09_action_route
```

也可写 `path=`（路径含空格时推荐）：

```text
js-load path=Samples/Scripts/Js/01_hello.js
```

| Cmdlet | 运行时 |
|--------|--------|
| `lisp-load` | 进程内 HQ-LISP Session |
| `js-load` | 随包 Node；宿主注入 `hqeda_client` |
| `python-load` | 随包 Python；同上 |
| `go-load` | `script.go.run` 短别名（TinyGo WASI；需 `PCB_ENABLE_GOSCRIPT=ON`） |

**连接 vs 后续 API**：脚本模式 `connect` / `Connect` 走 `PCB_HOST_DIR` 宿主桥（与 SDK Flight socket 不同）；连接之后的方法名与语义以 Flight `ClientFactory` 为准（`wsOpen` / `doAction` / `ping` / `caps` 等）。UI 自动化等 Flight 未覆盖能力仍用 `cli.cmdlet(...)` 逃生舱。

交互脚本经宿主 cmdlet：`action.start` / `action.input` / `action.current` / `sleep.ms`。

相对路径会自应用目录上溯仓库根探测，因此从 `.app` 启动也可写 `Samples/Scripts/...`。
