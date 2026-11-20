// 弹出工程打开对话框选板，再 OpenAndWait 打开。
//
// Usage:
//
//	go-load Samples/Scripts/Go/11_choose_file
//
// 连接：NewConnection（宿主桥）；选文件：cli.ChooseFile（file.choose）。
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

	hqeda.Log(";; ChooseFile: pick a .hqpcb / .hqpcbx …")
	board, err := cli.ChooseFile()
	if err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	hqeda.Log(";; chosen " + board)

	if _, err := cli.OpenAndWait(board, 30000); err != nil {
		hqeda.Log(err.Error())
		os.Exit(1)
	}
	_ = cli.ZoomAll()
	hqeda.Log(";; open ok")
}
