#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""methods.list。用法：./run 02_methods_list.py [headless|gui]"""

from __future__ import annotations

import sys

from helper import ensure_sdk_path, resolve_pipe

ensure_sdk_path()
from hqeda_client import ClientFactory  # noqa: E402


def main(argv: list[str]) -> int:
    pipe, gui, _ = resolve_pipe(argv)
    cli = ClientFactory()
    cli.connect(pipe, gui=gui)
    catalog = cli.methods_list()
    print(f"# pipe={cli.pipe} role={cli.peer_role}")
    print(catalog.rstrip())
    core = sum(1 for ln in catalog.splitlines() if "surface=core" in ln)
    ix = sum(1 for ln in catalog.splitlines() if "surface=interactive" in ln)
    print(f"# count core={core} interactive={ix}")
    cli.disconnect()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
