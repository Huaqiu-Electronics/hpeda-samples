package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/Huaqiu-Electronics/hpeda-samples/sdk/go/helper"
	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
)

func main() {
	_, gui, _ := helper.ResolvePipe(os.Args)
	a, err := helper.BoardPath("", "tracks")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	b, err := helper.BoardPath("", "components")
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

	fmt.Printf("pipe=%s\n", cli.Pipe())
	fmt.Println("--- open A (tracks) ---")
	snapA, err := cli.WsOpen(a)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	idA := hqeda.WorkspaceID(snapA)
	fmt.Println(strings.TrimRight(snapA, "\n"))
	fmt.Println("--- open B (components) ---")
	snapB, err := cli.WsOpen(b)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	idB := hqeda.WorkspaceID(snapB)
	fmt.Println(strings.TrimRight(snapB, "\n"))
	fmt.Println("--- ws.list ---")
	list, err := cli.WsList()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(strings.TrimRight(list, "\n"))

	if idA != "" && idB != "" && idA != idB {
		fmt.Printf("--- ws.switch → A id=%s ---\n", idA)
		out, err := cli.WsSwitch(idA)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Println(strings.TrimRight(out, "\n"))
		fmt.Printf("--- ws.close B id=%s ---\n", idB)
		out, err = cli.WsClose(idB)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Println(strings.TrimRight(out, "\n"))
	} else {
		cur := hqeda.WorkspaceID(list)
		if cur == "" {
			cur = idB
		}
		if cur == "" {
			cur = idA
		}
		fmt.Printf("--- ws.close id=%s ---\n", cur)
		if cur != "" {
			out, err := cli.WsClose(cur)
			if err != nil {
				fmt.Fprintln(os.Stderr, err)
				os.Exit(1)
			}
			fmt.Println(strings.TrimRight(out, "\n"))
		}
	}
	fmt.Println("--- ws.list (after) ---")
	list, err = cli.WsList()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(strings.TrimRight(list, "\n"))
}
