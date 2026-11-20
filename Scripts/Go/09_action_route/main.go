// 对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。
//
// Usage:
//
//	go-load Samples/Scripts/Go/09_action_route
//
// 连接：NewClientFactory().Connect（宿主桥）；开板：cli.WsOpen（与 SDK 同名）。
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

func resolveBoard(cli *hqeda.ClientFactory) (string, error) {
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

func main() {
	stepMs := envInt("PCB_STEP_MS", 60)
	afterStart := envInt("PCB_AFTER_START_MS", 200)

	cli := hqeda.NewClientFactory()
	if err := cli.Connect("", true); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	pause := func() {
		_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", stepMs))
	}

	board, err := resolveBoard(cli)
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; open " + board)
	if _, err := cli.WsOpen(board); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	pause()
	_, _ = hqeda.Cmdlet("rasternext.wait_open_follow 30000")
	pause()
	_, _ = hqeda.Cmdlet("zoomall")
	pause()

	cur, _ := hqeda.Cmdlet("action.current")
	hqeda.Log(";; action-current (before) = " + cur)
	_, _ = hqeda.Cmdlet("layer_schema.select Conductor1")
	pause()
	if _, err := hqeda.Cmdlet("action.start route"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	pause()
	cur, _ = hqeda.Cmdlet("action.current")
	hqeda.Log(";; action-current (after start) = " + cur)

	_, _ = hqeda.Cmdlet("action.input move-line 6 -6 18 -15 8")
	_, _ = hqeda.Cmdlet("action.input move 18 -15")
	_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", 80))
	_, _ = hqeda.Cmdlet("action.input click 18 -15")
	pause()
	_, _ = hqeda.Cmdlet(fmt.Sprintf("sleep.ms %d", afterStart))

	_, _ = hqeda.Cmdlet("action.input move-line 18 -15 28 -10 10")
	_, _ = hqeda.Cmdlet("action.input click 28 -10")
	pause()

	_, _ = hqeda.Cmdlet("action.input dbclick 28 -10")
	pause()

	_, _ = hqeda.Cmdlet("action.cancel")
	pause()

	cur, _ = hqeda.Cmdlet("action.current")
	hqeda.Log(";; action-current (after via+cancel) = " + cur)
	_, _ = hqeda.Cmdlet("zoomall")
	pause()
	hqeda.Log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")
}
