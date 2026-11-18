#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 01_tracks_vias：nets / vias。也可用 05_arc_tracks_vias 测 microvia。

用法：./run 06_nets_vias.py [headless] [board.hqpcb]
"""

from __future__ import annotations

import sys

from _env import board_path, ensure_sdk_path, require_ws_design, resolve_pipe

ensure_sdk_path()
from pcb_api_gen import Board, bind_flight_ipc  # noqa: E402
from pcb_flight_IPC import PcbFlightIPC  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="tracks")
    cli = PcbFlightIPC()
    cli.connect(pipe, gui=gui)
    if (rc := require_ws_design(cli)) is not None:
        cli.disconnect()
        return rc
    board = Board.open(bind_flight_ipc(cli), str(path))
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
