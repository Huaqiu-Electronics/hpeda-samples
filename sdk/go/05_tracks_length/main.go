package main

import (
	"fmt"
	"os"
	"sort"

	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
	"github.com/Huaqiu-Electronics/hpeda-samples/sdk/go/helper"
)

func main() {
	pipe, gui, rest := helper.ResolvePipe(os.Args)
	arg := ""
	if len(rest) > 0 {
		arg = rest[0]
	}
	path, err := helper.BoardPath(arg, "arc_tracks")
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
	tracks, err := board.Tracks(false)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("track_count=%d\n", len(tracks))
	for i, t := range tracks {
		if i >= 8 {
			break
		}
		fmt.Printf("  net=%q w=%.4f len=%.4f\n", t.GetNetname(), t.WidthMm, t.Length())
	}
	byNet, err := board.LengthByNet()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	type kv struct {
		k string
		v float64
	}
	items := make([]kv, 0, len(byNet))
	total := 0.0
	for k, v := range byNet {
		items = append(items, kv{k, v})
		total += v
	}
	sort.Slice(items, func(i, j int) bool { return items[i].v > items[j].v })
	fmt.Printf("nets_with_tracks=%d total_mm=%.4f\n", len(items), total)
	for i, it := range items {
		if i >= 10 {
			break
		}
		fmt.Printf("  %q total_mm=%.4f\n", it.k, it.v)
	}
}
