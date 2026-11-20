// 主脚本 ↔ 本目录小程序：传 prompt，等对话框回传路径，再 OpenAndWait。
//
// Usage:
//
//	go-load Samples/Scripts/Go/12_mp_open_board
package main

import (
	"net/url"
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

	manifest, err := cli.ResolveFile("Samples/Scripts/Go/12_mp_open_board/plugin.yaml")
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; loadplugin " + manifest)
	if _, err := hqeda.Cmdlet("loadplugin " + manifest); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	// 脚本 → 小程序：写入提示文案。
	if _, err := hqeda.Cmdlet("mp.slot.clear"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	put := "mp.slot.put key=" + url.QueryEscape("prompt") +
		" value=" + url.QueryEscape("Go 脚本：请选一块样板板再 OK")
	if _, err := hqeda.Cmdlet(put); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	hqeda.Log(";; open MP dialog (go_mp_open_board)")
	if _, err := hqeda.Cmdlet("go_mp_open_board"); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}

	// 小程序 → 脚本：阻塞等待 result。
	hqeda.Log(";; wait mp.slot.result …")
	board, err := hqeda.Cmdlet("mp.slot.wait 300000")
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	if board == "" {
		hqeda.Log("empty board path from mp.slot")
		os.Exit(1)
	}
	hqeda.Log(";; mp returned " + board)

	if _, err := cli.OpenAndWait(board, 30000); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.ZoomAll()
	hqeda.Log(";; open ok")
}
