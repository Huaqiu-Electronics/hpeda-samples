#!/usr/bin/env python3
"""Minimal PCB_HOST_TO_GUEST server: accept pcb-wit-run client (tip E2E).

Does not push events; only keeps the socket open so the runner can start.
"""
from __future__ import annotations

import socket
import sys
import time
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: host_to_guest_accept.py <sock_path>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    if path.exists():
        path.unlink()
    path.parent.mkdir(parents=True, exist_ok=True)
    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(str(path))
    srv.listen(1)
    srv.settimeout(0.2)
    deadline = time.time() + 30.0
    print(f"host-to-guest listen {path}", flush=True)
    conn = None
    while time.time() < deadline:
        try:
            conn, _ = srv.accept()
            print("host-to-guest accepted", flush=True)
            break
        except socket.timeout:
            continue
    # Hold until deadline so runner can finish one-shot guest.
    while conn is not None and time.time() < deadline:
        time.sleep(0.2)
    if conn is not None:
        conn.close()
    srv.close()
    try:
        path.unlink()
    except OSError:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
