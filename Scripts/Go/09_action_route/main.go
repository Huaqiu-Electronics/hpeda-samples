// 对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。
//
// Usage:
//
//	go-load Samples/Scripts/Go/09_action_route
//
// 连接：NewConnection（宿主桥）；开板：cli.Open（与 SDK 同名）。
package main

import (
	"os"
	"strconv"

	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
)

func envInt(key string, def int) int {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return def
	}
	return n
}

func main() {
	stepMs := envInt("PCB_STEP_MS", 60)
	afterStart := envInt("PCB_AFTER_START_MS", 200)

	cli, err := hqeda.NewConnection(true)
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	defer cli.Disconnect()

	board := os.Getenv("PCB_BOARD")
	if board == "" {
		board, err = cli.ResolveFile("Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")
		if err != nil {
			hqeda.Log(err.Error())
			os.Exit(1)
		}
	}
	hqeda.Log(";; open " + board)
	if _, err := cli.OpenAndWait(board, 30000); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.SleepMs(stepMs)
	_ = hqeda.ZoomAll()
	_ = cli.SleepMs(stepMs)

	cur, _ := hqeda.CurrentAction()
	hqeda.Log(";; action-current (before) = " + cur)
	_ = cli.SelectLayer("Conductor1")
	_ = cli.SleepMs(stepMs)
	if err := hqeda.StartAction("route"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.SleepMs(stepMs)
	cur, _ = hqeda.CurrentAction()
	hqeda.Log(";; action-current (after start) = " + cur)

	_ = hqeda.MouseMoveEx(6, -6, 18, -15, 8)
	_ = cli.SleepMs(80)
	_ = hqeda.MouseClick(18, -15)
	_ = cli.SleepMs(stepMs)
	_ = cli.SleepMs(afterStart)

	_ = hqeda.MouseMoveEx(18, -15, 28, -10, 10)
	_ = hqeda.MouseClick(28, -10)
	_ = cli.SleepMs(stepMs)

	_ = hqeda.MouseDBClick(28, -10)
	_ = cli.SleepMs(stepMs)

	_ = hqeda.CancelAction()
	_ = cli.SleepMs(stepMs)

	cur, _ = hqeda.CurrentAction()
	hqeda.Log(";; action-current (after via+cancel) = " + cur)
	_ = hqeda.ZoomAll()
	_ = cli.SleepMs(stepMs)

	// Pick 测试：选中 (12,-20) 走线，再 HideItems（内部 setStaticObjectsVisibleByIds）。
	hqeda.Log(";; pick test at (12,-20)")
	pickIds, err := cli.PickAt(12, -20)
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; pick ids = %v", pickIds)
	if len(pickIds) == 0 {
		hqeda.Log("pick miss at (12,-20)")
		os.Exit(1)
	}
	hideOut, err := cli.HideItems(pickIds)
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; hideItems = " + hideOut)
	_ = cli.SleepMs(stepMs)

	hqeda.Log(";; done: route + pick(12,-20) + hideItems")
}
