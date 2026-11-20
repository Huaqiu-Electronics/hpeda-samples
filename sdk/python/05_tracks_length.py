#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 05_arc_tracks_vias：tracks + length_by_net。

用法：./run 05_tracks_length.py [headless] [board.hqpcbx]
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import new_connection  # noqa: E402


def main(argv: list[str]) -> int:
    _, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="arc_tracks")
    cli = new_connection(gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc
    board = cli.open_board(str(path))
    print(f"pipe={cli.pipe} path={board.path}")
    tracks = board.tracks()
    print(f"track_count={len(tracks)}")
    for t in tracks[:8]:
        print(
            f"  net={t.get_netname()!r} layer={t.get_layer()!r} "
            f"w={t.get_width():.4f} len={t.length():.4f} seg_type={t.seg_type}"
        )
    by_net = board.length_by_net()
    print(f"nets_with_tracks={len(by_net)} total_mm={sum(by_net.values()):.4f}")
    for net, ln in sorted(by_net.items(), key=lambda kv: kv[1], reverse=True)[:10]:
        print(f"  {net!r} total_mm={ln:.4f}")
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
