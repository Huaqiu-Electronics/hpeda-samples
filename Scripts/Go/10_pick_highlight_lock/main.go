// 对齐 Lisp 10_pick_highlight_lock：pick → highlight/dehighlight → lock/unlock → hide。
//
// 对齐菜单：
//
//	View/Highlight、View/Dehighlight
//	Edit/Lock、Edit/Unlock
//
// 流程：PickAt 选中后 StartAction，工具对当前选择集立即 apply，再 CancelAction 退出并切回 Conductor1。
//
// Usage:
//
//	go-load Samples/Scripts/Go/10_pick_highlight_lock
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

func envFloat(key string, def float64) float64 {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	n, err := strconv.ParseFloat(v, 64)
	if err != nil {
		return def
	}
	return n
}

func main() {
	stepMs := envInt("PCB_STEP_MS", 60)
	pickX := envFloat("PCB_PICK_X", 12)
	pickY := envFloat("PCB_PICK_Y", -20)

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

	// 先切到 Conductor1，保证 (12,-20) 走线可命中。
	_ = cli.SelectLayer("Conductor1")
	_ = cli.SleepMs(stepMs)

	pickOrDie := func() []int64 {
		hqeda.Log(";; pick at (%g,%g)", pickX, pickY)
		ids, e := cli.PickAt(pickX, pickY)
		if e != nil {
			hqeda.Log(e.Error())
			os.Exit(1)
		}
		hqeda.Log(";; pick ids = %v", ids)
		if len(ids) == 0 {
			hqeda.Log("pick miss at (%g,%g)", pickX, pickY)
			os.Exit(1)
		}
		return ids
	}

	// cancel 后切回 Conductor1，避免工具退出后层态漂移导致后续 pick 落空。
	cancelToConductor1 := func() {
		_ = hqeda.CancelAction()
		_ = cli.SelectLayer("Conductor1")
		_ = cli.SleepMs(stepMs)
	}

	// 选中文档坐标处对象（与菜单先选中再点 Highlight/Lock 一致）。
	_ = pickOrDie()

	// View/Highlight：对当前选择集上色，工具保持激活，cancel 退出。
	hqeda.Log(";; highlight (menu View/Highlight)")
	if err := hqeda.StartAction("highlight"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.SleepMs(stepMs)
	cancelToConductor1()

	// apply 后选择集已清；再 pick 一次做 Dehighlight。
	_ = pickOrDie()
	hqeda.Log(";; dehighlight (menu View/Dehighlight)")
	if err := hqeda.StartAction("dehighlight"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.SleepMs(stepMs)
	cancelToConductor1()

	// Edit/Lock → Edit/Unlock。
	_ = pickOrDie()
	hqeda.Log(";; lock (menu Edit/Lock)")
	if err := hqeda.StartAction("lock"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.SleepMs(stepMs)
	cancelToConductor1()

	_ = pickOrDie()
	hqeda.Log(";; unlock (menu Edit/Unlock)")
	if err := hqeda.StartAction("unlock"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.SleepMs(stepMs)
	cancelToConductor1()

	// 再 pick 后 HideItems（内部 setStaticObjectsVisibleByIds）。
	pickIds := pickOrDie()
	hideOut, err := cli.HideItems(pickIds)
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; hideItems = " + hideOut)
	_ = cli.SleepMs(stepMs)

	hqeda.Log(";; done: pick + highlight/dehighlight + lock/unlock + hide")
}
