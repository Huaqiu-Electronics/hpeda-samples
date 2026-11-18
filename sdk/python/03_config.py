#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""config.set / get（写+读）。用法：./run 03_config.py [headless] [key] [value]"""

from __future__ import annotations

import sys

from _env import ensure_sdk_path, resolve_pipe

ensure_sdk_path()
from pcb_flight_IPC import PcbFlightIPC  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, rest = resolve_pipe(argv)
    key = rest[0] if rest else "sample.theme"
    value = rest[1] if len(rest) > 1 else "dark"
    cli = PcbFlightIPC()
    cli.connect(pipe, gui=gui)
    print(cli.config_set(key, value).rstrip())
    got = cli.config_get(key)
    print(f"{key}={got}")
    cli.disconnect()
    return 0 if got == value else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
