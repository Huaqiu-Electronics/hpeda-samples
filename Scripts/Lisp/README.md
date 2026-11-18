# HQ-LISP 样例

需 `-DPCB_ENABLE_LISP=ON` 构建。在 Console / Telnet 中：

```text
lisp-load Samples/Scripts/Lisp/01_hello.lsp
lisp-eval (+ 1 2)
mode lisp
```

| 文件 | 说明 |
|------|------|
| `01_hello.lsp` | 纯 Scheme 算术 |
| `02_define.lsp` | `define` / `lambda` / `let` |
| `03_cmdlet_mode.lsp` | `(cmdlet "mode")` 桥接 |
| `04_cmdlet_calc.lsp` | `(cmdlet "calc …")` 调用近程表达式 |
| `05_begin.lsp` | 多形式 `begin` 与打印式返回 |

路径须落在 Session load 白名单（工程根、仓库根、`Scripts/`、`Samples/Scripts/Lisp`、应用目录等）。相对路径会先试进程 cwd，再在白名单根下解析，因此在 `.app` 内启动时仍可写：

```text
lisp-load Samples/Scripts/Lisp/01_hello.lsp
```
