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

移动器件（对齐 `13_action_move_component.lsp`：开板 → `move_component` → 框选 → 参考点 → 跟手 → 放下 → 保存）：

```text
lisp-load   Samples/Scripts/Lisp/13_action_move_component.lsp
js-load     Samples/Scripts/Js/13_action_move_component.js
python-load Samples/Scripts/Python/13_action_move_component.py
go-load     Samples/Scripts/Go/13_action_move_component
```

拾取 / Highlight / Lock（对齐 `10_pick_highlight_lock.lsp`；菜单 View/Highlight、Edit/Lock）：

```text
lisp-load   Samples/Scripts/Lisp/10_pick_highlight_lock.lsp
js-load     Samples/Scripts/Js/10_pick_highlight_lock.js
python-load Samples/Scripts/Python/10_pick_highlight_lock.py
go-load     Samples/Scripts/Go/10_pick_highlight_lock
```

选择文件再开板（`chooseFile` / `choose_file` / `ChooseFile` / `(choose-file)` → `file.choose`）：

```text
lisp-load   Samples/Scripts/Lisp/11_choose_file.lsp
js-load     Samples/Scripts/Js/11_choose_file.js
python-load Samples/Scripts/Python/11_choose_file.py
go-load     Samples/Scripts/Go/11_choose_file
```

自定义小程序对话框开板（小程序在各语言 `12_mp_open_board/` 目录内，与主脚本双向交互）：

```text
js-load     Samples/Scripts/Js/12_mp_open_board/12_mp_open_board.js
python-load Samples/Scripts/Python/12_mp_open_board/12_mp_open_board.py
go-load     Samples/Scripts/Go/12_mp_open_board
```

流程：`loadplugin` 本目录 → `mp.slot.clear` + `mp.slot.put prompt=…`（脚本→对话框）→ 打开对话框 → 用户 Browse/OK → `mp.slot.put result=` + `finish`（对话框→脚本）→ `mp.slot.wait` 取路径 → 脚本 `openAndWait`。Cancel 走 `mp.slot.cancel`。

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

**连接 vs 后续 API**：推荐 `NewConnection(true)` / `createConnection(true)` / `new_connection(True)` 一键建连。脚本模式连接走 `PCB_HOST_DIR` 宿主桥（与 SDK Flight socket 不同）；连接之后的方法名与语义以 Flight `ClientFactory` 为准（`open` / `openAndWait` / `doAction` / `ping` / `caps` 等）。UI 自动化等 Flight 未覆盖能力仍用 `cli.cmdlet(...)` 逃生舱。

交互脚本经宿主 cmdlet：`action.start` / `action.input` / `action.current`。停顿用 `cli.sleepMs` / `cli.sleep_ms` / `cli.SleepMs`（内部走 `sleep.ms`）。

相对路径会自应用目录上溯仓库根探测，因此从 `.app` 启动也可写 `Samples/Scripts/...`。
