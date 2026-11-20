# Go SDK 示例

`go.mod` 通过 `replace` 指向仓库内 `sdk/go/hqeda`。默认打开 `Samples/Boards/hqpcbx` 对应板。

```bash
cd Samples/sdk/go
./run 01_hello_ping
./run 06_nets_vias
./run 11_design_write
./run 12_workspace_write
./run 07_footprints_pads headless ../../Boards/hqpcbx/08_blind_bottom.hqpcbx
```

建连：`cli, err := hqeda.NewConnection(gui)`（`gui` 来自 `helper.ResolvePipe` / `ResolveEndpoint`）。  
写路径：[sdk/docs/Flight-Write-API.md](../../../sdk/docs/Flight-Write-API.md)。详见 [../README.md](../README.md)。
