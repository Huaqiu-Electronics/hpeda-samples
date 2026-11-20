#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""读 11_diffpair_route：design_settings / net_classes / track_widths / via_defs。

也可用 06_keepout_netclass。

用法：./run 09_netclasses.py [headless] [board.hqpcbx]
"""

from __future__ import annotations

import sys

from helper import board_path, ensure_sdk_path, check_env, resolve_pipe

ensure_sdk_path()
from hqeda_client import new_connection  # noqa: E402


def main(argv: list[str]) -> int:
    _, gui, rest = resolve_pipe(argv)
    path = board_path(rest[0] if rest else None, preset="diffpair")
    cli = new_connection(gui)
    if (rc := check_env(cli)) is not None:
        cli.disconnect()
        return rc
    board = cli.open_board(str(path))
    print(f"pipe={cli.pipe} path={board.path}")
    ds = board.design_settings()
    print(
        f"default_track_width_mm={ds.default_track_width_mm:.4f} "
        f"clearance={ds.default_clearance_mm:.4f} "
        f"via_dia={ds.via_diameter_mm:.4f}"
    )
    classes = board.net_classes()
    print(f"net_class_count={len(classes)}")
    for nc in classes:
        print(
            f"  {nc.name!r} members={nc.member_count} "
            f"width={nc.width_rule!r} via={nc.default_via!r}"
        )
    widths = board.track_widths()
    print(f"track_width_count={len(widths)}")
    for w in widths[:6]:
        print(f"  {w.name!r} def={w.default_width_mm:.4f} min={w.min_width_mm:.4f}")
    vias = board.via_defs()
    print(f"via_def_count={len(vias)}")
    for v in vias[:6]:
        print(f"  {v.padstack_name!r} is_via={v.is_via}")
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
