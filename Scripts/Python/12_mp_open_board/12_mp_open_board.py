# -*- coding: utf-8 -*-
"""主脚本 ↔ 本目录小程序：传 prompt，等对话框回传路径，再 open_and_wait。

Usage:
  python-load Samples/Scripts/Python/12_mp_open_board/12_mp_open_board.py
"""

from __future__ import annotations

from urllib.parse import quote

from hqeda_client import new_connection


def main() -> None:
    cli = new_connection(True)
    manifest = cli.resolve_file(
        "Samples/Scripts/Python/12_mp_open_board/plugin.yaml"
    )
    cli.log(f";; loadplugin {manifest}")
    cli.cmdlet(f"loadplugin {manifest}")

    # 脚本 → 小程序：写入提示文案。
    cli.cmdlet("mp.slot.clear")
    cli.cmdlet(
        "mp.slot.put key="
        f"{quote('prompt', safe='')} value="
        f"{quote('Python 脚本：请选一块样板板再 OK', safe='')}"
    )

    cli.log(";; open MP dialog (py_mp_open_board)")
    cli.cmdlet("py_mp_open_board")

    # 小程序 → 脚本：阻塞等待 result。
    cli.log(";; wait mp.slot.result …")
    board = str(cli.cmdlet("mp.slot.wait 300000") or "").strip()
    if not board:
        raise RuntimeError("empty board path from mp.slot")
    cli.log(f";; mp returned {board}")

    cli.open_and_wait(board, 30000)
    cli.zoom_all()
    cli.log(";; open ok")


if __name__ == "__main__":
    main()
