package main

import (
	"fmt"
	"os"

	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
	"github.com/Huaqiu-Electronics/hpeda-samples/sdk/go/helper"
)

func main() {
	pipe, gui, rest := helper.ResolvePipe(os.Args)
	arg := ""
	if len(rest) > 0 {
		arg = rest[0]
	}
	path, err := helper.BoardPath(arg, "keepout")
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
	zones, err := board.Zones()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("zone_count=%d\n", len(zones))
	for i, z := range zones {
		if i >= 10 {
			break
		}
		fmt.Printf("  id=%v name=%q net=%q\n", z["id"], z["name"], z["net"])
	}
	drawings, err := board.Drawings()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("drawing_count=%d\n", len(drawings))
	bbox, err := board.BoundingBox()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("bbox=%v\n", bbox)
}
