/**
 * route 样例：开板 → route → 锁角/线宽 → 起点 → 末点 dbclick 打 via → cancel → save。
 * Pick / Highlight / Lock 见 10_pick_highlight_lock.js。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/09_action_route.js
 */
"use strict";

const { createConnection } = require("hqeda_client");

const cli = createConnection(true);
const board = cli.resolveFile("Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx");

cli.openAndWait(board, 30000);
cli.zoomAll();
cli.selectLayer("Conductor1");
cli.startAction("route");

// Angle Lock → 90°（index=1）；Line width → 0.4mm。
cli.setActionParam("angleLock", 1);
cli.setActionParam("lineWidth", 0.4);

cli.mouseMoveEx(0, 0, 18, -15, 8);
cli.mouseClick(18, -15);
cli.mouseMoveEx(18, -15, 28, -10, 10);
cli.mouseDBClick(28, -10);

cli.cancelAction();
cli.save();
cli.zoomAll();
