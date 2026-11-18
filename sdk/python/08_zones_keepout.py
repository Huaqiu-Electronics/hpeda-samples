#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 06_keepout_netclass：zones / drawings / bounding_box。

也可用 03_zones_graphics / 09_slots_thermals。

用法：./run 08_zones_keepout.py [headless] [board.hqpcb]
"""

from __future__ import annotations

import sys

from _env import board_path, ensure_sdk_path, require_ws_design, resolve_pipe

ensure_sdk_path()
from pcb_api_gen import Board, bind_flight_ipc  # noqa: E402
from pcb_flight_IPC import PcbFlightIPC  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="keepout")
    cli = PcbFlightIPC()
    cli.connect(pipe, gui=gui)
    if (rc := require_ws_design(cli)) is not None:
        cli.disconnect()
        return rc
    board = Board.open(bind_flight_ipc(cli), str(path))
    print(f"pipe={cli.pipe} path={board.path}")
    zones = board.zones()
    print(f"zone_count={len(zones)}")
    for z in zones[:10]:
        print(
            f"  id={z.id} name={z.name!r} net={z.net!r} filled={z.is_filled} "
            f"bbox=({z.min_x_mm:.3f},{z.min_y_mm:.3f})-({z.max_x_mm:.3f},{z.max_y_mm:.3f})"
        )
    drawings = board.drawings()
    print(f"drawing_count={len(drawings)}")
    for d in drawings[:8]:
        print(
            f"  kind={d.kind} id={d.id} name={d.name!r} "
            f"xy=({d.x_mm:.3f},{d.y_mm:.3f}) filled={d.is_filled}"
        )
    bbox = board.bounding_box()
    print(
        f"bbox=({bbox.min_x_mm:.4f},{bbox.min_y_mm:.4f})-"
        f"({bbox.max_x_mm:.4f},{bbox.max_y_mm:.4f}) "
        f"size={bbox.width_mm:.4f}x{bbox.height_mm:.4f} mm"
    )
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
