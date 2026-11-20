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
	path, err := helper.BoardPath(arg, "diffpair")
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
	ds, err := board.DesignSettings()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("default_track_width_mm=%s clearance=%s via_dia=%s\n",
		ds["default_track_width_mm"], ds["default_clearance_mm"], ds["via_diameter_mm"])
	classes, err := board.NetClasses()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("net_class_count=%d\n", len(classes))
	for _, nc := range classes {
		fmt.Printf("  %q members=%v\n", nc["name"], nc["member_count"])
	}
}
