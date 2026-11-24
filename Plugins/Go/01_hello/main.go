// Samples Go WASM hello plugin — 常驻事件循环，注册命令后弹提示。
//
// 加载：loadplugin Samples/Plugins/Go/01_hello/plugin.yaml
// 需构建开启 PCB_ENABLE_GOSCRIPT=ON（fast 预设默认 OFF）。
package main

import (
	pcb "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
)

const cmdHello = "samples_go_hello"

func main() {
	pcb.HandleCommand(cmdHello, func(name string) error {
		return pcb.ShowMessage("Hello from Samples/Plugins/Go/01_hello", 0, 4000)
	})

	pcb.OnLifecycle("onAppInit", func() error {
		return pcb.RegisterCommand(cmdHello, "Samples Go Hello", "Minimal Go WASM plugin sample")
	})

	pcb.Run()
}
