#!/usr/bin/env python3
"""Minimal PCB_HOST_RPC server: line JSON ↔ ok resp (for pcb-wit-run Log E2E)."""
from __future__ import annotations

import json
import os
import socket
import sys
import threading
import time
from pathlib import Path


def handle(conn: socket.socket) -> None:
    buf = b""
    with conn:
        while True:
            chunk = conn.recv(4096)
            if not chunk:
                return
            buf += chunk
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                line = line.strip()
                if not line:
                    continue
                try:
                    body = json.loads(line.decode("utf-8"))
                except Exception as exc:  # noqa: BLE001
                    resp = {"ok": False, "error": str(exc)}
                else:
                    op = body.get("op", "")
                    args = body.get("args") or {}
                    msg = args.get("message", "")
                    print(f"rpc<{op}>: {msg}", flush=True)
                    resp = {"ok": True, "result": ""}
                conn.sendall((json.dumps(resp) + "\n").encode("utf-8"))


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: rpc_host.py <sock_path>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    if path.exists():
        path.unlink()
    path.parent.mkdir(parents=True, exist_ok=True)
    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(str(path))
    srv.listen(8)
    srv.settimeout(0.2)
    deadline = time.time() + 30.0
    print(f"rpc listen {path}", flush=True)
    while time.time() < deadline:
        try:
            conn, _ = srv.accept()
        except socket.timeout:
            continue
        threading.Thread(target=handle, args=(conn,), daemon=True).start()
    srv.close()
    try:
        path.unlink()
    except OSError:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
