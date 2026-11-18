#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""工作区写：打开两块样板、切换、关闭。

用法：
  ./run 12_workspace_write.py
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import ClientFactory  # noqa: E402
from hqeda_write import workspace_id  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, _ = resolve_pipe(argv)
    a = board_path(None, preset="tracks")
    b = board_path(None, preset="components")
    cli = ClientFactory()
    cli.connect(pipe, gui=gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc

    print(f"pipe={cli.pipe}")
    print("--- open A (tracks) ---")
    snap_a = cli.ws_open(str(a))
    id_a = workspace_id(snap_a)
    print(snap_a.rstrip())
    print("--- open B (components) ---")
    snap_b = cli.ws_open(str(b))
    id_b = workspace_id(snap_b)
    print(snap_b.rstrip())
    print("--- ws.list ---")
    print(cli.ws_list().rstrip())

    if id_a and id_b and id_a != id_b:
        print(f"--- ws.switch → A id={id_a} ---")
        print(cli.ws_switch(id_a).rstrip())
        print(f"--- ws.close B id={id_b} ---")
        print(cli.ws_close(id_b).rstrip())
    else:
        cur = workspace_id(cli.ws_list()) or id_b or id_a
        print(f"--- ws.close id={cur} ---")
        if cur:
            print(cli.ws_close(cur).rstrip())

    print("--- ws.list (after) ---")
    print(cli.ws_list().rstrip())
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
