# -*- coding: utf-8 -*-
"""对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。

Usage:
  python-load Samples/Scripts/Python/09_action_route.py

纸面 mm：VCC via @ (18,-15)；途经点/打孔点 @ (28,-10)。
覆盖：环境变量 PCB_BOARD / PCB_STEP_MS / PCB_MOVE_GAP_MS / PCB_AFTER_START_MS。
"""

from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import quote

import pcb_host as pcb

STEP_MS = int(os.environ.get("PCB_STEP_MS", "60"))
MOVE_GAP_MS = int(os.environ.get("PCB_MOVE_GAP_MS", "10"))
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


def act_move_line(x0: float, y0: float, x1: float, y1: float, n: int) -> None:
    steps = 1 if n < 1 else n
    for i in range(steps):
        t = 1.0 if steps == 1 else i / (steps - 1)
        x = x0 + t * (x1 - x0)
        y = y0 + t * (y1 - y0)
        pcb.cmdlet(f"action.input move {x} {y}")
        pcb.sleep_ms(MOVE_GAP_MS)
    pause()


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

    act_move_line(6.0, -6.0, 18.0, -15.0, 8)
    pcb.cmdlet("action.input move 18 -15")
    pcb.sleep_ms(80)
    pcb.cmdlet("action.input click 18 -15")
    pause()
    pcb.sleep_ms(AFTER_START_MS)

    act_move_line(18.0, -15.0, 28.0, -10.0, 10)
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
