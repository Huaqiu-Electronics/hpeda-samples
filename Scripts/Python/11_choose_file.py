# -*- coding: utf-8 -*-
"""弹出工程打开对话框选板，再 open_and_wait 打开。

Usage:
  python-load Samples/Scripts/Python/11_choose_file.py

连接：new_connection（宿主桥）；
选文件：cli.choose_file（file.choose）；取消时抛错。
"""

from __future__ import annotations

from hqeda_client import new_connection


def main() -> None:
    cli = new_connection(True)

    cli.log(";; choose_file: pick a .hqpcb / .hqpcbx …")
    board = cli.choose_file()
    cli.log(f";; chosen {board}")

    cli.open_and_wait(board, 30000)
    cli.zoom_all()
    cli.log(";; open ok")


if __name__ == "__main__":
    main()
