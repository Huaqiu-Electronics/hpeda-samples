#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""设计租约写：批量 props + 错 token 拒写（默认板 01_tracks_vias）。

用法：
  ./run 11_design_write.py
  ./run 11_design_write.py headless ../../Boards/hqpcbx/04_all_basics.hqpcbx
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
    print("--- open_board ---")
    board = cli.open_board(str(path))
    print(f"path={board.path}")

    print("--- write_props (lease batch) ---")
    got = cli.write_props(
        {
            "sample.note": "from-11-design-write",
            "sample.layer": "top",
            "sample.rev": "1",
        },
        token="samples-sdk-write",
    )
    for k, v in got.items():
        print(f"{k}={v}")

    print("--- reject wrong token while holding lease ---")
    with cli.write_lease("holder-A") as w:
        w.set("sample.guard", "held-by-A")
        try:
            cli.design_set("sample.guard", "stolen", "holder-B")
            print("error: expected not_writer", file=sys.stderr)
            return 1
        except Exception as ex:  # Flight 侧 Invalid → RuntimeError
            print(f"ok reject: {ex}")
        print(f"sample.guard={w.get('sample.guard')}")

    if got.get("sample.note") != "from-11-design-write":
        return 1
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
