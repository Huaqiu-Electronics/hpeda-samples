# -*- coding: utf-8 -*-
"""对齐 Js 09_action_route：route → 锁角/线宽 → 起点 → dbclick via → cancel → save。

Usage:
  python-load Samples/Scripts/Python/09_action_route.py
"""

from __future__ import annotations

from hqeda_client import new_connection


def main() -> None:
    cli = new_connection(True)
    board = cli.resolve_file("Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx")

    cli.open_and_wait(board, 30000)
    cli.zoom_all()
    cli.select_layer("Conductor1")
    cli.start_action("route")

    # Angle Lock → 90°（index=1）；Line width → 0.4mm。
    cli.set_action_param("angleLock", 1)
    cli.set_action_param("lineWidth", 0.4)

    cli.mouse_move_ex(0, 0, 18, -15, 8)
    cli.mouse_click(18, -15)
    cli.mouse_move_ex(18, -15, 28, -10, 10)
    cli.mouse_db_click(28, -10)

    cli.cancel_action()
    cli.save()
    cli.zoom_all()


if __name__ == "__main__":
    main()
