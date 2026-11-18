# -*- coding: utf-8 -*-
"""Samples/sdk/python 共用：端点解析、Boards/hqpcb 默认板、SDK 路径。"""

from __future__ import annotations

import os
import sys
from pathlib import Path

_SVC_TOKENS = frozenset({"headless", "service", "svc", "--headless", "--service"})
_GUI_TOKENS = frozenset({"gui", "--gui"})
_SVC_PIPES = frozenset({"hqpcb-svc"})
_GUI_PIPES = frozenset({"hqpcb-gui"})

# 示例名 → Boards/hqpcb 默认文件
BOARD_PRESETS: dict[str, str] = {
    "tracks": "01_tracks_vias.hqpcb",
    "arc_tracks": "05_arc_tracks_vias.hqpcb",
    "components": "02_components_pads.hqpcb",
    "zones": "03_zones_graphics.hqpcb",
    "all_basics": "04_all_basics.hqpcb",
    "keepout": "06_keepout_netclass.hqpcb",
    "custom_pads": "07_custom_pads_curves.hqpcb",
    "blind": "08_blind_bottom.hqpcb",
    "slots": "09_slots_thermals.hqpcb",
    "outline": "10_outline_arcs.hqpcb",
    "diffpair": "11_diffpair_route.hqpcb",
}


def samples_root() -> Path:
    """返回 Samples/ 根目录。"""
    return Path(__file__).resolve().parents[2]


def boards_hqpcb_dir() -> Path:
    """返回 Samples/Boards/hqpcb。"""
    return samples_root() / "Boards" / "hqpcb"


def sdk_python_dir() -> Path:
    """返回仓库 sdk/python（相对 Samples/sdk/python）。"""
    return samples_root().parent / "sdk" / "python"


def ensure_sdk_path() -> None:
    """保证可 import pcb_flight_IPC / pcb_api_gen。"""
    root = str(sdk_python_dir())
    if root not in sys.path:
        sys.path.insert(0, root)


def resolve_pipe(argv: list[str]) -> tuple[str | None, bool, list[str]]:
    """解析 headless/gui 端点与剩余参数。"""
    rest = list(argv[1:])
    gui = False
    pipe: str | None = None
    env_ep = os.environ.get("PCB_IPC_ENDPOINT", "").strip().lower()
    if env_ep in ("gui", "hqpcb-gui"):
        gui = True
    elif env_ep in ("headless", "service", "svc", "hqpcb-svc"):
        gui = False
    out: list[str] = []
    for a in rest:
        low = a.lower()
        if a.startswith("grpc") or "://" in a or a.endswith(".sock"):
            print("error: 不要传 Flight URI / socket 路径。", file=sys.stderr)
            raise SystemExit(2)
        if low.startswith("--endpoint="):
            val = low.split("=", 1)[1].strip()
            if val in ("gui", "hqpcb-gui"):
                gui, pipe = True, None
            elif val in ("headless", "service", "svc", "hqpcb-svc"):
                gui, pipe = False, None
            else:
                print(f"error: unknown --endpoint={val}", file=sys.stderr)
                raise SystemExit(2)
            continue
        if low in _GUI_TOKENS:
            gui, pipe = True, None
            continue
        if low in _SVC_TOKENS:
            gui, pipe = False, None
            continue
        if low in _GUI_PIPES:
            gui, pipe = True, a
            continue
        if low in _SVC_PIPES:
            gui, pipe = False, a
            continue
        out.append(a)
    return pipe, gui, out


def board_path(arg: str | None, *, preset: str) -> Path:
    """解析板路径：显式参数优先，否则 Boards/hqpcb 预设。"""
    if arg:
        path = Path(arg).expanduser().resolve()
    else:
        name = BOARD_PRESETS.get(preset, preset)
        path = (boards_hqpcb_dir() / name).resolve()
    if not path.is_file():
        print(f"error: board not found: {path}", file=sys.stderr)
        print(f"hint: convert via Samples/Boards/convert_to_hqpcb.sh", file=sys.stderr)
        raise SystemExit(1)
    return path


def require_ws_design(cli) -> int | None:
    """对端缺 workspace/design 时返回 1。"""
    if cli.peer_caps.workspace and cli.peer_caps.design:
        return None
    print(
        f"peer lacks workspace/design (pipe={cli.pipe} role={cli.peer_role})\n"
        "请连 hqpcb-svc 或已声明 workspace+design 的 hqpcb-gui。",
        file=sys.stderr,
    )
    return 1
