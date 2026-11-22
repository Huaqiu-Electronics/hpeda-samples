# -*- coding: utf-8 -*-
"""对齐 Js 13：move_component → 框选 → 参考点 → 跟手 → 放下 → 保存。

板：02_components_pads（R1@12,-12；C1@28,-12）。
接口走 hqeda_client 封装，不直接拼 cmdlet。

Usage:
  python-load Samples/Scripts/Python/13_action_move_component.py
"""

from __future__ import annotations

from hqeda_client import new_connection


def main() -> None:
    cli = new_connection(True)
    board = cli.resolve_file("Samples/Boards/hqpcbx/02_components_pads.hqpcbx")

    cli.open_and_wait(board, 30000)
    cli.zoom_all()
    cli.start_action("move_component")

    # 左→右框选 R1+C1（Intersect）。
    cli.mouse_box_select(8, -16, 32, -8, 10)

    # 参考点：R1 中心。
    cli.mouse_click(12, -12)

    # 跟手平移约 +6,+6 mm 后放下。
    cli.mouse_move_ex(12, -12, 18, -6, 12)
    cli.mouse_click(18, -6)

    cli.save()
    cli.zoom_all()


if __name__ == "__main__":
    main()
