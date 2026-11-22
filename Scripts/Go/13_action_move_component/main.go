// 对齐 Js 13：move_component → 框选 → 参考点 → 跟手 → 放下 → 保存。
//
// 板：02_components_pads（R1@12,-12；C1@28,-12）。
// 接口走 hqeda 封装，不直接拼 cmdlet。
//
// Usage:
//
//	go-load Samples/Scripts/Go/13_action_move_component
package main

import (
	"os"

	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
)

func main() {
	cli, err := hqeda.NewConnection(true)
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	defer cli.Disconnect()

	board, err := cli.ResolveFile("Samples/Boards/hqpcbx/02_components_pads.hqpcbx")
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	if _, err := cli.OpenAndWait(board, 30000); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.ZoomAll()
	if err := hqeda.StartAction("move_component"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	// 左→右框选 R1+C1（Intersect）。
	if err := hqeda.MouseBoxSelect(8, -16, 32, -8, 10); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	// 参考点：R1 中心。
	if err := hqeda.MouseClick(12, -12); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	// 跟手平移约 +6,+6 mm 后放下。
	_ = hqeda.MouseMoveEx(12, -12, 18, -6, 12)
	if err := hqeda.MouseClick(18, -6); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	if _, err := cli.Save(); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.ZoomAll()
}
