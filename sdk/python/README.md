# Python SDK 示例

依赖仓库 `sdk/python/.venv`。默认打开 `Samples/Boards/hqpcb` 对应板。

```bash
cd Samples/sdk/python
./run 01_hello_ping.py
./run 06_nets_vias.py
./run 11_design_write.py          # 设计租约写
./run 12_workspace_write.py       # 工作区 open/switch/close
./run 07_footprints_pads.py headless ../../Boards/hqpcb/08_blind_bottom.hqpcb
```

端点：`hqeda_endpoint.resolve_endpoint`（样例经 `helper.resolve_pipe`）。  
写路径文档：[sdk/docs/Flight-Write-API.md](../../../sdk/docs/Flight-Write-API.md)。详见 [../README.md](../README.md)。
