// File-bridge adapter: exports hqpcb:host/op, implements via PCB_HOST_DIR req/resp.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"wasip2_wit_bridge/adapter/hqpcb/host/op"
	"go.bytecodealliance.org/cm"
)

func init() {
	op.Exports.Log = func(message string) {
		_, _ = fileCall("log", map[string]interface{}{"message": message})
	}
	op.Exports.Cmdlet = func(line string) cm.Result[string, string, string] {
		return fileResult(fileCall("cmdlet", map[string]interface{}{"line": line}))
	}
	op.Exports.Query = func(sql string) cm.Result[string, string, string] {
		return fileResult(fileCall("query", map[string]interface{}{"sql": sql}))
	}
	op.Exports.DoAction = func(method, body string) cm.Result[string, string, string] {
		return fileResult(fileCall("doAction", map[string]interface{}{"method": method, "body": body}))
	}
	op.Exports.Call = func(name, argsJSON string) cm.Result[string, string, string] {
		var args map[string]interface{}
		if argsJSON != "" {
			_ = json.Unmarshal([]byte(argsJSON), &args)
		}
		if args == nil {
			args = map[string]interface{}{}
		}
		return fileResult(fileCall(name, args))
	}
}

func main() {}

type hostReq struct {
	Op   string                 `json:"op"`
	Args map[string]interface{} `json:"args"`
}

type hostResp struct {
	OK     bool   `json:"ok"`
	Result string `json:"result"`
	Error  string `json:"error"`
}

func fileCall(opName string, args map[string]interface{}) (string, error) {
	root := os.Getenv("PCB_HOST_DIR")
	if root == "" {
		return "", fmt.Errorf("PCB_HOST_DIR not set")
	}
	id := fmt.Sprintf("%d", time.Now().UnixNano())
	reqPath := filepath.Join(root, "req", id+".json")
	respPath := filepath.Join(root, "resp", id+".json")
	body, err := json.Marshal(hostReq{Op: opName, Args: args})
	if err != nil {
		return "", err
	}
	if err := os.WriteFile(reqPath, body, 0o600); err != nil {
		return "", err
	}
	deadline := time.Now().Add(30 * time.Second)
	for time.Now().Before(deadline) {
		data, err := os.ReadFile(respPath)
		if err != nil {
			time.Sleep(10 * time.Millisecond)
			continue
		}
		if len(bytes.TrimSpace(data)) == 0 {
			time.Sleep(10 * time.Millisecond)
			continue
		}
		var resp hostResp
		if err := json.Unmarshal(data, &resp); err != nil {
			time.Sleep(10 * time.Millisecond)
			continue
		}
		_ = os.Remove(reqPath)
		_ = os.Remove(respPath)
		if !resp.OK {
			if resp.Error == "" {
				return "", fmt.Errorf("host call failed")
			}
			return "", fmt.Errorf("%s", resp.Error)
		}
		return resp.Result, nil
	}
	return "", fmt.Errorf("host call timeout")
}

func fileResult(s string, err error) cm.Result[string, string, string] {
	if err != nil {
		return cm.Err[cm.Result[string, string, string]](err.Error())
	}
	return cm.OK[cm.Result[string, string, string]](s)
}
