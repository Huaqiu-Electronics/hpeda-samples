package main

import (
	"fmt"
	"os"
	"strings"

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

	fmt.Printf("pipe=%s\n", cli.Pipe())
	fmt.Println("--- OpenBoard ---")
	board, err := cli.OpenBoard(path)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("path=%s\n", board.Path)

	fmt.Println("--- WriteProps (lease batch) ---")
	got, err := cli.WriteProps(map[string]string{
		"sample.note":  "from-11-design-write",
		"sample.layer": "top",
		"sample.rev":   "1",
	}, "samples-sdk-write")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	for k, v := range got {
		fmt.Printf("%s=%s\n", k, v)
	}

	fmt.Println("--- reject wrong token while holding lease ---")
	token := "holder-A"
	if _, err := cli.DesignLease(token); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if _, err := cli.DesignSet("sample.guard", "held-by-A", token); err != nil {
		fmt.Fprintln(os.Stderr, err)
		_, _ = cli.DesignRelease(token)
		os.Exit(1)
	}
	if _, err := cli.DesignSet("sample.guard", "stolen", "holder-B"); err == nil {
		fmt.Fprintln(os.Stderr, "error: expected not_writer")
		_, _ = cli.DesignRelease(token)
		os.Exit(1)
	} else {
		fmt.Printf("ok reject: %v\n", err)
	}
	guard, err := cli.DesignGet("sample.guard")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		_, _ = cli.DesignRelease(token)
		os.Exit(1)
	}
	fmt.Printf("sample.guard=%s\n", guard)
	if out, err := cli.DesignRelease(token); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	} else {
		fmt.Println(strings.TrimRight(out, "\n"))
	}

	if got["sample.note"] != "from-11-design-write" {
		os.Exit(1)
	}
}
