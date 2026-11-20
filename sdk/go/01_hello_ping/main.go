package main

import (
	"fmt"
	"os"

	"github.com/Huaqiu-Electronics/hpeda-samples/sdk/go/helper"
	hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"
)

func main() {
	ep := helper.ResolveEndpoint(os.Args) // 内部为 hqeda.ResolveEndpoint
	cli, err := hqeda.NewConnection(ep.Gui)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer cli.Disconnect()
	echo, err := cli.Ping("samples-sdk-01")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	caps, err := cli.Caps()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Printf("pipe=%s\nrole=%s\nping=%s\n", cli.Pipe(), cli.PeerRole(), echo)
	fmt.Printf("caps interactive=%v workspace=%v design=%v ver=%d.%d\n",
		caps.Interactive, caps.Workspace, caps.Design, caps.VerMajor, caps.VerMinor)
}
