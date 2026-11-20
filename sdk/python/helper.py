# -*- coding: utf-8 -*-
"""Samples/sdk/python 共用：板路径等；端点解析用 hqeda_endpoint.resolve_endpoint。"""

from __future__ import annotations

import sys
from pathlib import Path

# 示例名 → Boards/hqpcbx 默认文件（文本工程）
BOARD_PRESETS: dict[str, str] = {
    "tracks": "01_tracks_vias.hqpcbx",
    "arc_tracks": "05_arc_tracks_vias.hqpcbx",
    "components": "02_components_pads.hqpcbx",
    "zones": "03_zones_graphics.hqpcbx",
    "all_basics": "04_all_basics.hqpcbx",
    "keepout": "06_keepout_netclass.hqpcbx",
    "custom_pads": "07_custom_pads_curves.hqpcbx",
    "blind": "08_blind_bottom.hqpcbx",
    "slots": "09_slots_thermals.hqpcbx",
    "outline": "10_outline_arcs.hqpcbx",
    "diffpair": "11_diffpair_route.hqpcbx",
}


def samples_root() -> Path:
    """返回 Samples/ 根目录。"""
    return Path(__file__).resolve().parents[2]


def boards_hqpcbx_dir() -> Path:
    """返回 Samples/Boards/hqpcbx。"""
    return samples_root() / "Boards" / "hqpcbx"


# 兼容旧名
boards_hqpcb_dir = boards_hqpcbx_dir


def sdk_python_dir() -> Path:
    """返回仓库 sdk/python。"""
    return samples_root().parent / "sdk" / "python"


def ensure_sdk_path() -> None:
    """保证可 import hqeda_*。"""
    root = str(sdk_python_dir())
    if root not in sys.path:
        sys.path.insert(0, root)


ensure_sdk_path()
from hqeda_endpoint import resolve_endpoint, resolve_endpoint_pipe  # noqa: E402


def resolve_pipe(argv: list[str]):
    """兼容旧名：委托 SDK resolve_endpoint_pipe；非法端点退出 2。"""
    try:
        return resolve_endpoint_pipe(argv)
    except ValueError as ex:
        print(f"error: {ex}", file=sys.stderr)
        raise SystemExit(2) from ex


def board_path(arg: str | None, *, preset: str) -> Path:
    """解析板路径：显式参数优先，否则 Boards/hqpcbx 预设。"""
    if arg:
        path = Path(arg).expanduser().resolve()
    else:
        name = BOARD_PRESETS.get(preset, preset)
        path = (boards_hqpcbx_dir() / name).resolve()
    if not path.is_file():
        print(f"error: board not found: {path}", file=sys.stderr)
        print("hint: convert via Samples/Boards/convert_to_hqpcb.sh --hqpcbx-only", file=sys.stderr)
        raise SystemExit(1)
    return path


def check_env(cli) -> int | None:
    """检查对端 workspace+design；缺能力时返回 1。"""
    if cli.peer_caps.workspace and cli.peer_caps.design:
        return None
    print(
        f"peer lacks workspace/design (pipe={cli.pipe} role={cli.peer_role})\n"
        "请连 hqpcb-svc 或已声明 workspace+design 的 hqpcb-gui。",
        file=sys.stderr,
    )
    return 1
