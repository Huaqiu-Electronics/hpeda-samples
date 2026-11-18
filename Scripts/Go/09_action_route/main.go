// 对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。
//
// Usage:
//
//	go-load Samples/Scripts/Go/09_action_route
//
// 纸面 mm：VCC via @ (18,-15)；途经点/打孔点 @ (28,-10)。
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

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

func resolveBoard() (string, error) {
	if p := os.Getenv("PCB_BOARD"); p != "" {
		return p, nil
	}
	rels := []string{
		"Samples/Boards/hqpcb/01_tracks_vias.hqpcb",
		"Boards/hqpcb/01_tracks_vias.hqpcb",
	}
	for _, rel := range rels {
		out, err := hqeda.CmdletLine("path.resolve", hqeda.KvToken("path", rel))
		if err != nil {
			continue
		}
		out = strings.TrimSpace(out)
		if out != "" {
			return out, nil
		}
	}
	return "", fmt.Errorf("board sample not found; set PCB_BOARD to an absolute .hqpcb path")
}

func pause(stepMs int) {
	_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", stepMs))
}

func actMoveLine(x0, y0, x1, y1 float64, n, moveGap, stepMs int) {
	steps := n
	if steps < 1 {
		steps = 1
	}
	for i := 0; i < steps; i++ {
		t := 1.0
		if steps > 1 {
			t = float64(i) / float64(steps-1)
		}
		x := x0 + t*(x1-x0)
		y := y0 + t*(y1-y0)
		_, _ = hqeda.Cmdlet(fmt.Sprintf("action.input move %g %g", x, y))
		_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", moveGap))
	}
	pause(stepMs)
}

func main() {
	stepMs := envInt("PCB_STEP_MS", 60)
	moveGap := envInt("PCB_MOVE_GAP_MS", 10)
	afterStart := envInt("PCB_AFTER_START_MS", 200)

	board, err := resolveBoard()
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; open " + board)
	if _, err := hqeda.ProjectOpen(board, hqeda.ProjectOpenOpts{}); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	pause(stepMs)
	_, _ = hqeda.Cmdlet("rasternext.wait_open_follow 30000")
	pause(stepMs)
	_, _ = hqeda.Cmdlet("zoomall")
	pause(stepMs)

	cur, _ := hqeda.Cmdlet("action.current")
	hqeda.Log(";; action-current (before) = " + cur)
	// 先切到 Conductor1（传层名），避免 From/To 在底层倒置导致末点 dbclick 打孔失败。
	_, _ = hqeda.Cmdlet("layer_schema.select Conductor1")
	pause(stepMs)
	if _, err := hqeda.Cmdlet("action.start route"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	pause(stepMs)
	cur, _ = hqeda.Cmdlet("action.current")
	hqeda.Log(";; action-current (after start) = " + cur)

	actMoveLine(6, -6, 18, -15, 8, moveGap, stepMs)
	_, _ = hqeda.Cmdlet("action.input move 18 -15")
	_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", 80))
	_, _ = hqeda.Cmdlet("action.input click 18 -15")
	pause(stepMs)
	_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", afterStart))

	actMoveLine(18, -15, 28, -10, 10, moveGap, stepMs)
	_, _ = hqeda.Cmdlet("action.input click 28 -10")
	pause(stepMs)

	// 末点 dbclick：双击打 via。
	_, _ = hqeda.Cmdlet("action.input dbclick 28 -10")
	pause(stepMs)

	_, _ = hqeda.Cmdlet("action.cancel")
	pause(stepMs)

	cur, _ = hqeda.Cmdlet("action.current")
	hqeda.Log(";; action-current (after via+cancel) = " + cur)
	_, _ = hqeda.Cmdlet("zoomall")
	pause(stepMs)
	hqeda.Log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")
}
