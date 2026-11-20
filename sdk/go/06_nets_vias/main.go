package main

import (
	"fmt"
	"os"

	"github.com/Huaqiu-Electronics/hpeda-samples/sdk/go/helper"
	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
)

func main() {
	_, gui, rest := helper.ResolvePipe(os.Args)
	arg := ""
	if len(rest) > 0 {
		arg = rest[0]
	}
	path, err := helper.BoardPath(arg, "tracks")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	cli, err := hqeda.NewConnection(gui)
	if err != nil {
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
	nets, err := board.Nets()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("net_count=%d\n", len(nets))
	for i, n := range nets {
		if i >= 10 {
			break
		}
		fmt.Printf("  net code=%v name=%q\n", n["code"], n["name"])
	}
	vias, err := board.Vias()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("via_count=%d\n", len(vias))
	for i, v := range vias {
		if i >= 8 {
			break
		}
		fmt.Printf("  via id=%v net=%q layers=%v->%v\n",
			v["id"], v["net"], v["layer_from_id"], v["layer_to_id"])
	}
}
