#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""打开 Boards/01_tracks_vias + design 租约读写。

用法：
  ./run 04_workspace_rw.py
  ./run 04_workspace_rw.py headless ../../Boards/hqpcb/04_all_basics.hqpcb
"""

from __future__ import annotations

import sys

from _env import board_path, ensure_sdk_path, require_ws_design, resolve_pipe

ensure_sdk_path()
from pcb_flight_IPC import PcbFlightIPC  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="tracks")
    cli = PcbFlightIPC()
    cli.connect(pipe, gui=gui)
    if (rc := require_ws_design(cli)) is not None:
        cli.disconnect()
        return rc
    print(f"pipe={cli.pipe}")
    print("--- ws.open ---")
    print(cli.ws_open(str(path)).rstrip())
    print(f"gen={cli.ws_gen()}")
    token = "samples-sdk-rw"
    print("--- design.lease / set / get / release ---")
    print(cli.design_lease(token).rstrip())
    print(cli.design_set("sample.note", "from-samples-sdk", token).rstrip())
    print(f"sample.note={cli.design_get('sample.note')}")
    print(cli.design_release(token).rstrip())
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
