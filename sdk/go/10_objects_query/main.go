package main

import (
	"fmt"
	"os"
	"strings"

	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
	"github.com/Huaqiu-Electronics/hpeda-samples/sdk/go/helper"
)

func main() {
	pipe, gui, rest := helper.ResolvePipe(os.Args)
	arg := ""
	if len(rest) > 0 {
		arg = rest[0]
	}
	path, err := helper.BoardPath(arg, "all_basics")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	cli := hqeda.NewClientFactory()
	if err := cli.Connect(pipe, gui); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer cli.Disconnect()
	helper.CheckEnv(cli.Pipe(), cli.PeerRole(), cli.PeerCaps().Workspace, cli.PeerCaps().Design)
	board, err := cli.OpenBoard(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("pipe=%s path=%s\n", cli.Pipe(), board.Path)
	tracks, err := board.ObjectsList("tracks")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer tracks.Release()
	fmt.Printf("objects.list tracks rows=%d\n", tracks.NumRows())
	vias, err := board.ObjectsList("vias")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer vias.Release()
	fmt.Printf("objects.list vias rows=%d\n", vias.NumRows())
	_, err = board.QueryTable("sqlite_master")
	if err == nil {
		fmt.Fprintln(os.Stderr, "error: expected table_not_allowed")
		os.Exit(2)
	}
	msg := err.Error()
	if strings.Contains(msg, "table_not_allowed") {
		fmt.Println("reject_ok=table_not_allowed")
	} else {
		fmt.Printf("reject_ok=%s\n", msg)
	}
}
