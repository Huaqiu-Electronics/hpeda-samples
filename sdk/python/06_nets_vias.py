#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 01_tracks_vias：nets / vias。也可用 05_arc_tracks_vias 测 microvia。

用法：./run 06_nets_vias.py [headless] [board.hqpcb]
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import ClientFactory  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="tracks")
    cli = ClientFactory()
    cli.connect(pipe, gui=gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc
    board = cli.open_board(str(path))
    print(f"pipe={cli.pipe} path={board.path}")
    nets = board.nets()
    print(f"net_count={board.net_count()}")
    for n in nets[:10]:
        print(f"  net code={n.code} name={n.name!r} class={n.net_class!r}")
    vias = board.vias()
    print(f"via_count={len(vias)}")
    for v in vias[:8]:
        print(
            f"  via id={v.id} net={v.net!r} xy=({v.x_mm:.4f},{v.y_mm:.4f}) "
            f"layers={v.layer_from_id}->{v.layer_to_id}"
        )
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
