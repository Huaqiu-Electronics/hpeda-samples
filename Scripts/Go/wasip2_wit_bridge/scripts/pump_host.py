#!/usr/bin/env python3
"""Minimal PCB_HOST_DIR pump: ack every req/*.json with ok resp (for Log)."""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: pump_host.py <PCB_HOST_DIR>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1])
    req_dir = root / "req"
    resp_dir = root / "resp"
    req_dir.mkdir(parents=True, exist_ok=True)
    resp_dir.mkdir(parents=True, exist_ok=True)
    seen: set[str] = set()
    deadline = time.time() + 30.0
    while time.time() < deadline:
        for path in sorted(req_dir.glob("*.json")):
            if path.name in seen:
                continue
            seen.add(path.name)
            try:
                body = json.loads(path.read_text(encoding="utf-8"))
            except Exception as exc:  # noqa: BLE001
                print(f"bad req {path}: {exc}", file=sys.stderr)
                continue
            op = body.get("op", "")
            args = body.get("args") or {}
            msg = args.get("message", "")
            print(f"host<{op}>: {msg}", flush=True)
            resp = {"ok": True, "result": ""}
            out = resp_dir / path.name
            tmp = out.with_suffix(".part")
            tmp.write_text(json.dumps(resp), encoding="utf-8")
            os.replace(tmp, out)
        time.sleep(0.01)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
