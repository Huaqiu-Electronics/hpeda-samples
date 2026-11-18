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
	path, err := helper.BoardPath(arg, "tracks")
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
	fmt.Printf("pipe=%s\n", cli.Pipe())
	fmt.Println("--- ws.open ---")
	snap, err := cli.WsOpen(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(strings.TrimRight(snap, "\n"))
	token := "samples-sdk-rw"
	fmt.Println("--- design.lease / set / get / release ---")
	out, err := cli.DesignLease(token)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(strings.TrimRight(out, "\n"))
	out, err = cli.DesignSet("sample.note", "from-samples-sdk", token)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(strings.TrimRight(out, "\n"))
	note, err := cli.DesignGet("sample.note")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("sample.note=%s\n", note)
	out, err = cli.DesignRelease(token)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(strings.TrimRight(out, "\n"))
}
