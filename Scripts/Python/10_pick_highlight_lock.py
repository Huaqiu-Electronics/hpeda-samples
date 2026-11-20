# -*- coding: utf-8 -*-
"""对齐 Lisp 10_pick_highlight_lock：pick → highlight/dehighlight → lock/unlock → hide。

对齐菜单：
  View/Highlight、View/Dehighlight
  Edit/Lock、Edit/Unlock
流程：pick_at 选中后 start_action，工具对当前选择集立即 apply，再 cancel 退出并切回 Conductor1。

Usage:
  python-load Samples/Scripts/Python/10_pick_highlight_lock.py

连接：new_connection（宿主桥）；开板：cli.open（与 SDK 同名）。
"""

from __future__ import annotations

import os

from hqeda_client import new_connection

STEP_MS = int(os.environ.get("PCB_STEP_MS", "60"))
PICK_X = float(os.environ.get("PCB_PICK_X", "12"))
PICK_Y = float(os.environ.get("PCB_PICK_Y", "-20"))


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

    # 先切到 Conductor1，保证 (12,-20) 走线可命中。
    cli.select_layer("Conductor1")
    cli.sleep_ms(STEP_MS)

    def pick_or_throw() -> list[int]:
        cli.log(f";; pick at ({PICK_X},{PICK_Y})")
        ids = cli.pick_at(PICK_X, PICK_Y)
        cli.log(f";; pick ids = {ids}")
        if not ids:
            raise RuntimeError(f"pick miss at ({PICK_X},{PICK_Y})")
        return ids

    def cancel_to_conductor1() -> None:
        # cancel 后切回 Conductor1，避免工具退出后层态漂移导致后续 pick 落空。
        cli.cancel_action()
        cli.select_layer("Conductor1")
        cli.sleep_ms(STEP_MS)

    # 选中文档坐标处对象（与菜单先选中再点 Highlight/Lock 一致）。
    pick_or_throw()

    # View/Highlight：对当前选择集上色，工具保持激活，cancel 退出。
    cli.log(";; highlight (menu View/Highlight)")
    cli.start_action("highlight")
    cli.sleep_ms(STEP_MS)
    cancel_to_conductor1()

    # apply 后选择集已清；再 pick 一次做 Dehighlight。
    pick_or_throw()
    cli.log(";; dehighlight (menu View/Dehighlight)")
    cli.start_action("dehighlight")
    cli.sleep_ms(STEP_MS)
    cancel_to_conductor1()

    # Edit/Lock → Edit/Unlock。
    pick_or_throw()
    cli.log(";; lock (menu Edit/Lock)")
    cli.start_action("lock")
    cli.sleep_ms(STEP_MS)
    cancel_to_conductor1()

    pick_or_throw()
    cli.log(";; unlock (menu Edit/Unlock)")
    cli.start_action("unlock")
    cli.sleep_ms(STEP_MS)
    cancel_to_conductor1()

    # 再 pick 后 hide_items（内部 setStaticObjectsVisibleByIds）。
    pick_ids = pick_or_throw()
    hide_out = cli.hide_items(pick_ids)
    cli.log(f";; hide_items = {hide_out}")
    cli.sleep_ms(STEP_MS)

    cli.log(";; done: pick + highlight/dehighlight + lock/unlock + hide")


if __name__ == "__main__":
    main()
