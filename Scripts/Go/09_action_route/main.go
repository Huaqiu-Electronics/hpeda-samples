// 对齐 Js 09_action_route：route → 锁角/线宽 → 起点 → dbclick via → cancel → save。
//
// Usage:
//
//	go-load Samples/Scripts/Go/09_action_route
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

	board, err := cli.ResolveFile("Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	if _, err := cli.OpenAndWait(board, 30000); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.ZoomAll()
	_ = cli.SelectLayer("Conductor1")
	if err := hqeda.StartAction("route"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	// Angle Lock → 90°（index=1）；Line width → 0.4mm。
	if _, err := cli.SetActionParam("angleLock", 1); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	if _, err := cli.SetActionParam("lineWidth", 0.4); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	_ = hqeda.MouseMoveEx(0, 0, 18, -15, 8)
	_ = hqeda.MouseClick(18, -15)
	_ = hqeda.MouseMoveEx(18, -15, 28, -10, 10)
	_ = hqeda.MouseDBClick(28, -10)

	_ = hqeda.CancelAction()
	if _, err := cli.Save(); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.ZoomAll()
}
