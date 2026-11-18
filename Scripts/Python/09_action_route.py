# -*- coding: utf-8 -*-
"""对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。

Usage:
  python-load Samples/Scripts/Python/09_action_route.py

纸面 mm：VCC via @ (18,-15)；途经点/打孔点 @ (28,-10)。
覆盖：环境变量 PCB_BOARD / PCB_STEP_MS / PCB_AFTER_START_MS。
"""

from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import quote

import pcb_host as pcb

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


def pause() -> None:
    pcb.sleep_ms(STEP_MS)


def main() -> None:
    board = resolve_board()
    pcb.log(f";; open {board}")
    pcb.cmdlet(f"project.open path={quote(board, safe='')}")
    pause()
    pcb.cmdlet("rasternext.wait_open_follow 30000")
    pause()
    pcb.cmdlet("zoomall")
    pause()

    pcb.log(";; action-current (before) = " + pcb.cmdlet("action.current"))
    # 先切到 Conductor1（传层名），避免 From/To 在底层倒置导致末点 dbclick 打孔失败。
    pcb.cmdlet("layer_schema.select Conductor1")
    pcb.cmdlet("action.start route")
    pause()
    pcb.log(";; action-current (after start) = " + pcb.cmdlet("action.current"))

    pcb.cmdlet("action.input move-line 6 -6 18 -15 8")
    pcb.cmdlet("action.input move 18 -15")
    pcb.sleep_ms(80)
    pcb.cmdlet("action.input click 18 -15")
    pause()
    pcb.sleep_ms(AFTER_START_MS)

    pcb.cmdlet("action.input move-line 18 -15 28 -10 10")
    pcb.cmdlet("action.input click 28 -10")
    pause()

    # 末点 dbclick：双击打 via。
    pcb.cmdlet("action.input dbclick 28 -10")
    pause()

    pcb.cmdlet("action.cancel")
    pause()

    pcb.log(";; action-current (after via+cancel) = " + pcb.cmdlet("action.current"))
    pcb.cmdlet("zoomall")
    pause()
    pcb.log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall")


if __name__ == "__main__":
    main()
