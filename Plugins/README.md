# Samples/Plugins

多语言**插件**最小示例（对齐 `plugin.yaml` + 生命周期注册 cmdlet；与 [`Scripts/`](../Scripts/README.md) 的一键脚本加载不同）。

| 语言 | 目录 | runtime | 菜单 |
|------|------|---------|------|
| JavaScript | [`Js/01_hello`](./Js/01_hello/) | `javascript` | Plugins → Samples Js → Hello |
| Python | [`Python/01_hello`](./Python/01_hello/) | `python` | Plugins → Samples Python → Hello |
| Java | [`Java/01_hello`](./Java/01_hello/) | `java` | Plugins → Samples Java → Hello |
| Go | [`Go/01_hello`](./Go/01_hello/) | `go_wasm` | Plugins → Samples Go → Hello |

每个示例都会注册一条命令，点击菜单后弹出 `Hello from Samples/Plugins/...`。

## 加载方式

应用已启动且开了 cmdlet telnet（常见 `-T 5555`）时：

```text
loadplugin Samples/Plugins/Js/01_hello/plugin.yaml
loadplugin Samples/Plugins/Python/01_hello/plugin.yaml
loadplugin Samples/Plugins/Java/01_hello/plugin.yaml
loadplugin Samples/Plugins/Go/01_hello/plugin.yaml
```

或用启动 profile（路径相对本文件所在目录）：

```bash
# 仓库根
./HQ\ PCB -P Samples/Plugins/startup-plugins.sample.yaml
```

也可写 `path=`（路径含空格时推荐）：

```text
loadplugin path=Samples/Plugins/Js/01_hello/plugin.yaml
```

相对路径会自应用目录上溯仓库根探测，因此从 `.app` 启动也可写 `Samples/Plugins/...`。

## 各语言注意

### JavaScript / Python

源码即入口，无需预编译。宿主桥在 `onAppInit` 注册命令；菜单由 `plugin.yaml` 的 `menus` 声明。

### Java

先打包（JAR 须内嵌 `Plugins/SDK/java` 宿主门面类）：

```bash
cd Samples/Plugins/Java/01_hello
mvn -q package
```

`plugin.yaml` 的 `entry` 指向 `target/samples-java-hello.jar`。`pom.xml` 通过 `build-helper-maven-plugin` 引入仓库内 `Plugins/SDK/java`（须在 PCB_V5 树下构建）。

### Go（`go_wasm`）

常驻 TinyGo WASI 插件，宿主在装载时自动编译 `main.go`。需要：

1. 构建开启 **`PCB_ENABLE_GOSCRIPT=ON`**（`clion-*-fast` 预设默认 OFF）。
2. 应用已捆绑 TinyGo / Wasmtime / Guest SDK（见 [`GoScriptPlatform.md`](../../docs/07-插件与扩展/01-宿主与协议/GoScriptPlatform.md)）。

Guest 侧用 `pcb.OnLifecycle` / `pcb.RegisterCommand` / `pcb.Run()`；菜单仍写在 `plugin.yaml`。

## 与仓库其它示例的关系

| 位置 | 用途 |
|------|------|
| `Samples/Plugins/`（本目录） | 面向用户的最小多语言插件样板 |
| `Plugins/Samples/` | 宿主仓库内更完整的功能演示（QML / HQML / Native 等） |
| `Samples/Scripts/` | `js-load` / `python-load` / `go-load` 一次性脚本 |

完整插件 SDK 契约见 [`Plugins/SDK/README.md`](../../Plugins/SDK/README.md)。
