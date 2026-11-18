#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 04_all_basics：DoGet objects.list / query.table。

用法：./run 10_objects_query.py [headless] [board.hqpcb]
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import ClientFactory  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="all_basics")
    cli = ClientFactory()
    cli.connect(pipe, gui=gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc
    board = cli.open_board(str(path))
    print(f"pipe={cli.pipe} path={board.path}")
    tracks = board.objects_list("tracks")
    print(f"objects.list kind=tracks rows={tracks.num_rows} cols={tracks.column_names}")
    vias = board.objects_list("vias")
    print(f"objects.list kind=vias rows={vias.num_rows}")
    tbl = board.query_table("trace_segment")
    print(f"query.table table=trace_segment rows={tbl.num_rows}")
    try:
        board.query_table("sqlite_master")
        print("error: expected table_not_allowed", file=sys.stderr)
        return 2
    except Exception as exc:
        msg = str(exc)
        reason = "table_not_allowed" if "table_not_allowed" in msg else msg.split(".", 1)[0]
        print(f"reject_ok={type(exc).__name__}:{reason}")
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
