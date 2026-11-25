// Spike: wasip2 + hqeda file bridge (Log round-trip).
// Host must pump PCB_HOST_DIR/req → resp while this runs.
// go-load Samples/Scripts/Go/wasip2_bridge
package main

import hqeda "github.com/Huaqiu-Electronics/hqpcb-go-sdk"

func main() {
	hqeda.Log("wasip2-bridge-ok")
}
