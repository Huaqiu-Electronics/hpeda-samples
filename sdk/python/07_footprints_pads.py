#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 02_components_pads：footprints / pads / layers。

也可用 07_custom_pads_curves / 08_blind_bottom。

用法：./run 07_footprints_pads.py [headless] [board.hqpcb]
"""

from __future__ import annotations

import sys

from _env import board_path, ensure_sdk_path, require_ws_design, resolve_pipe

ensure_sdk_path()
from pcb_api_gen import Board, bind_flight_ipc  # noqa: E402
from pcb_flight_IPC import PcbFlightIPC  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="components")
    cli = PcbFlightIPC()
    cli.connect(pipe, gui=gui)
    if (rc := require_ws_design(cli)) is not None:
        cli.disconnect()
        return rc
    board = Board.open(bind_flight_ipc(cli), str(path))
    print(f"pipe={cli.pipe} path={board.path}")
    fps = board.footprints()
    print(f"footprint_count={len(fps)}")
    for fp in fps[:10]:
        print(
            f"  {fp.refdes} pkg={fp.package!r} "
            f"xy=({fp.x_mm:.4f},{fp.y_mm:.4f}) placed={fp.placed}"
        )
    pads = board.pads()
    print(f"pad_count={len(pads)}")
    for p in pads[:8]:
        print(
            f"  pin={p.pin_number!r}/{p.pin_name!r} net_id={p.net_id} "
            f"xy=({p.x_mm:.4f},{p.y_mm:.4f})"
        )
    layers = board.layers()
    print(f"layer_count={len(layers)} copper={board.copper_layer_count()}")
    for ly in layers[:8]:
        print(f"  id={ly.layer_id} name={ly.name!r} conductor={ly.is_conductor}")
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
