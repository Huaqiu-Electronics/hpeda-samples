#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""连接 Flight：ping / caps。用法：./run 01_hello_ping.py [headless|gui]"""

from __future__ import annotations

import sys

from helper import ensure_sdk_path, resolve_pipe

ensure_sdk_path()
from hqeda_client import ClientFactory  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, _ = resolve_pipe(argv)
    cli = ClientFactory()
    cli.connect(pipe, gui=gui)
    echo = cli.ping("samples-sdk-01")
    caps = cli.caps()
    print(f"pipe={cli.pipe}")
    print(f"role={cli.peer_role}")
    print(f"ping={echo}")
    print(
        f"caps interactive={caps.interactive} workspace={caps.workspace} "
        f"design={caps.design} ver={caps.ver_major}.{caps.ver_minor}"
    )
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
