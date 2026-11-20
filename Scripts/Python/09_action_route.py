# -*- coding: utf-8 -*-
"""对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。

Usage:
  python-load Samples/Scripts/Python/09_action_route.py

连接：new_connection（宿主桥）；开板：cli.open（与 SDK 同名）。
"""

from __future__ import annotations

import os

from hqeda_client import new_connection

STEP_MS = int(os.environ.get("PCB_STEP_MS", "60"))
AFTER_START_MS = int(os.environ.get("PCB_AFTER_START_MS", "200"))


def main() -> None:
    cli = new_connection(True)

    board = os.environ.get("PCB_BOARD", "").strip() or cli.resolve_file(
        "Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx"
    )
    cli.log(f";; open {board}")
    cli.open_and_wait(board, 30000)
    cli.sleep_ms(STEP_MS)
    cli.zoom_all()
    cli.sleep_ms(STEP_MS)

    cli.log(";; action-current (before) = " + cli.current_action())
    cli.select_layer("Conductor1")
    cli.start_action("route")
    cli.sleep_ms(STEP_MS)
    cli.log(";; action-current (after start) = " + cli.current_action())

    cli.mouse_move_ex(6, -6, 18, -15, 8)
    cli.sleep_ms(80)
    cli.mouse_click(18, -15)
    cli.sleep_ms(STEP_MS)
    cli.sleep_ms(AFTER_START_MS)

    cli.mouse_move_ex(18, -15, 28, -10, 10)
    cli.mouse_click(28, -10)
    cli.sleep_ms(STEP_MS)

    cli.mouse_db_click(28, -10)
    cli.sleep_ms(STEP_MS)

    cli.cancel_action()
    cli.sleep_ms(STEP_MS)

    cli.log(";; action-current (after via+cancel) = " + cli.current_action())
    cli.zoom_all()
    cli.sleep_ms(STEP_MS)
    cli.log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")


if __name__ == "__main__":
    main()
