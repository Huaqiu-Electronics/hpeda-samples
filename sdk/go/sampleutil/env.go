// Package sampleutil：Samples/sdk/go 共用端点解析与 Boards/hqpcb 默认板。
package sampleutil

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strings"
)

// BoardPresets 示例名 → Boards/hqpcb 文件名。
var BoardPresets = map[string]string{
	"tracks":      "01_tracks_vias.hqpcb",
	"arc_tracks":  "05_arc_tracks_vias.hqpcb",
	"components":  "02_components_pads.hqpcb",
	"zones":       "03_zones_graphics.hqpcb",
	"all_basics":  "04_all_basics.hqpcb",
	"keepout":     "06_keepout_netclass.hqpcb",
	"custom_pads": "07_custom_pads_curves.hqpcb",
	"blind":       "08_blind_bottom.hqpcb",
	"slots":       "09_slots_thermals.hqpcb",
	"outline":     "10_outline_arcs.hqpcb",
	"diffpair":    "11_diffpair_route.hqpcb",
}

// Endpoint 解析结果。
type Endpoint struct {
	Pipe string
	Gui  bool
	Rest []string
}

// ResolvePipe 解析 headless/gui。
func ResolvePipe(argv []string) (pipe string, gui bool, rest []string) {
	ep := ResolveEndpoint(argv)
	return ep.Pipe, ep.Gui, ep.Rest
}

// ResolveEndpoint 解析端点。
func ResolveEndpoint(argv []string) Endpoint {
	ep := Endpoint{}
	if env := strings.ToLower(strings.TrimSpace(os.Getenv("PCB_IPC_ENDPOINT"))); env != "" {
		switch env {
		case "gui", "hqpcb-gui":
			ep.Gui = true
		case "headless", "service", "svc", "hqpcb-svc":
			ep.Gui = false
		}
	}
	for _, a := range argv[1:] {
		low := strings.ToLower(a)
		if strings.HasPrefix(a, "grpc") || strings.Contains(a, "://") || strings.HasSuffix(a, ".sock") {
			fmt.Fprintln(os.Stderr, "error: 不要传 Flight URI / socket")
			os.Exit(2)
		}
		if strings.HasPrefix(low, "--endpoint=") {
			val := strings.TrimSpace(strings.SplitN(low, "=", 2)[1])
			switch val {
			case "gui", "hqpcb-gui":
				ep.Gui, ep.Pipe = true, ""
			case "headless", "service", "svc", "hqpcb-svc":
				ep.Gui, ep.Pipe = false, ""
			default:
				fmt.Fprintf(os.Stderr, "error: unknown --endpoint=%s\n", val)
				os.Exit(2)
			}
			continue
		}
		switch low {
		case "gui", "--gui":
			ep.Gui, ep.Pipe = true, ""
			continue
		case "headless", "service", "svc", "--headless", "--service":
			ep.Gui, ep.Pipe = false, ""
			continue
		case "hqpcb-gui":
			ep.Gui, ep.Pipe = true, a
			continue
		case "hqpcb-svc":
			ep.Gui, ep.Pipe = false, a
			continue
		}
		ep.Rest = append(ep.Rest, a)
	}
	return ep
}

func samplesRoot() string {
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		return "."
	}
	// sampleutil -> go -> sdk -> Samples
	return filepath.Clean(filepath.Join(filepath.Dir(file), "..", "..", ".."))
}

// BoardsDir 返回 Samples/Boards/hqpcb。
func BoardsDir() string {
	return filepath.Join(samplesRoot(), "Boards", "hqpcb")
}

// BoardPath 显式路径或预设板。
func BoardPath(arg, preset string) (string, error) {
	var p string
	if strings.TrimSpace(arg) != "" {
		abs, err := filepath.Abs(arg)
		if err != nil {
			return "", err
		}
		p = abs
	} else {
		name := BoardPresets[preset]
		if name == "" {
			name = preset
		}
		p = filepath.Join(BoardsDir(), name)
	}
	st, err := os.Stat(p)
	if err != nil || st.IsDir() {
		return "", fmt.Errorf("board not found: %s", p)
	}
	return p, nil
}

// RequireWsDesign 检查 caps。
func RequireWsDesign(pipe, role string, workspace, design bool) {
	if workspace && design {
		return
	}
	fmt.Fprintf(os.Stderr,
		"peer lacks workspace/design (pipe=%s role=%s)\n请连 hqpcb-svc 或已声明 workspace+design 的 hqpcb-gui。\n",
		pipe, role)
	os.Exit(1)
}
