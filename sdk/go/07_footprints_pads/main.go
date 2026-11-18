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
	path, err := helper.BoardPath(arg, "components")
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
	fps, err := board.Footprints()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("footprint_count=%d\n", len(fps))
	for i, fp := range fps {
		if i >= 10 {
			break
		}
		fmt.Printf("  %v pkg=%q\n", fp["refdes"], fp["package"])
	}
	pads, err := board.Pads()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("pad_count=%d\n", len(pads))
	layers, err := board.Layers()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("layer_count=%d\n", len(layers))
}
