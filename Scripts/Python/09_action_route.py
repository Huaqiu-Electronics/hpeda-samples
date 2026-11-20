# -*- coding: utf-8 -*-
"""对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。

Usage:
  python-load Samples/Scripts/Python/09_action_route.py

连接：ClientFactory().connect()（宿主桥）；开板：cli.ws_open（与 SDK 同名）。
"""

from __future__ import annotations

import os
from pathlib import Path

from hqeda_client import ClientFactory

STEP_MS = int(os.environ.get("PCB_STEP_MS", "60"))
AFTER_START_MS = int(os.environ.get("PCB_AFTER_START_MS", "200"))


def resolve_board() -> str:
    env = os.environ.get("PCB_BOARD", "").strip()
    if env:
        return env
    here = Path(__file__).resolve().parent
    for base in [here, *here.parents]:
        for rel in (
            Path("Samples/Boards/hqpcb/01_tracks_vias.hqpcb"),
            Path("Boards/hqpcb/01_tracks_vias.hqpcb"),
        ):
            cand = base / rel
            if cand.is_file():
                return str(cand)
    raise SystemExit("board sample not found; set PCB_BOARD to an absolute .hqpcb path")


def main() -> None:
    cli = ClientFactory()
    cli.connect()

    def pause() -> None:
        cli.sleep_ms(STEP_MS)

    board = resolve_board()
    cli.log(f";; open {board}")
    cli.ws_open(board)
    pause()
    cli.cmdlet("rasternext.wait_open_follow 30000")
    pause()
    cli.cmdlet("zoomall")
    pause()

    cli.log(";; action-current (before) = " + cli.cmdlet("action.current"))
    cli.cmdlet("layer_schema.select Conductor1")
    cli.cmdlet("action.start route")
    pause()
    cli.log(";; action-current (after start) = " + cli.cmdlet("action.current"))

    cli.cmdlet("action.input move-line 6 -6 18 -15 8")
    cli.cmdlet("action.input move 18 -15")
    cli.sleep_ms(80)
    cli.cmdlet("action.input click 18 -15")
    pause()
    cli.sleep_ms(AFTER_START_MS)

    cli.cmdlet("action.input move-line 18 -15 28 -10 10")
    cli.cmdlet("action.input click 28 -10")
    pause()

    cli.cmdlet("action.input dbclick 28 -10")
    pause()

    cli.cmdlet("action.cancel")
    pause()

    cli.log(";; action-current (after via+cancel) = " + cli.cmdlet("action.current"))
    cli.cmdlet("zoomall")
    pause()
    cli.log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")


if __name__ == "__main__":
    main()
