#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 02_components_pads：footprints / pads / layers。

也可用 07_custom_pads_curves / 08_blind_bottom。

用法：./run 07_footprints_pads.py [headless] [board.hqpcbx]
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import new_connection  # noqa: E402


def main(argv: list[str]) -> int:
    _, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="components")
    cli = new_connection(gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc
    board = cli.open_board(str(path))
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
