# JavaScript SDK 示例

依赖仓库 `sdk/javascript`（`npm install`）。默认打开 `Samples/Boards/hqpcb` 对应板。

```bash
cd Samples/sdk/javascript
./run 01_hello_ping.js
./run 06_nets_vias.js
./run 11_design_write.js
./run 12_workspace_write.js
./run 07_footprints_pads.js headless ../../Boards/hqpcb/08_blind_bottom.hqpcb
```

端点：`hqeda_endpoint.resolveEndpoint`（样例经 `helper.resolveEndpoint`）。  
写路径：[sdk/docs/Flight-Write-API.md](../../../sdk/docs/Flight-Write-API.md)。详见 [../README.md](../README.md)。
