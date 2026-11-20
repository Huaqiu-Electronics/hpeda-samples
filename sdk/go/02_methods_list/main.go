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
	cli, err := hqeda.NewConnection(gui)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer cli.Disconnect()
	catalog, err := cli.MethodsList()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("# pipe=%s role=%s\n", cli.Pipe(), cli.PeerRole())
	fmt.Println(strings.TrimRight(catalog, "\n"))
	core, ix := 0, 0
	for _, ln := range strings.Split(catalog, "\n") {
		if strings.Contains(ln, "surface=core") {
			core++
		}
		if strings.Contains(ln, "surface=interactive") {
			ix++
		}
	}
	fmt.Printf("# count core=%d interactive=%d\n", core, ix)
}
