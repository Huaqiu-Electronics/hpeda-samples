# Go SDK 示例

`go.mod` 通过 `replace` 指向仓库内 `sdk/go/pcb`。默认打开 `Samples/Boards/hqpcb` 对应板。

```bash
cd Samples/sdk/go
./run 01_hello_ping
./run 06_nets_vias
./run 07_footprints_pads headless ../../Boards/hqpcb/08_blind_bottom.hqpcb
```

详见 [../README.md](../README.md)。
