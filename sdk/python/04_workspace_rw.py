#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""打开 Boards/01_tracks_vias + design 租约读写。

用法：
  ./run 04_workspace_rw.py
  ./run 04_workspace_rw.py headless ../../Boards/hqpcbx/04_all_basics.hqpcbx
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import new_connection  # noqa: E402


def main(argv: list[str]) -> int:
    _, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="tracks")
    cli = new_connection(gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc
    print(f"pipe={cli.pipe}")
    print("--- ws.open ---")
    print(cli.ws_open(str(path)).rstrip())
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
