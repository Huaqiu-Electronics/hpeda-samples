/**
 * 对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/09_action_route.js
 *
 * 连接：脚本模式 createClientFactory().connect()（宿主桥）；
 * 开板：cli.wsOpen（与 SDK ClientFactory 同名）。
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { createClientFactory } = require("hqeda_client");

const STEP_MS = Number(process.env.PCB_STEP_MS || 60);
const AFTER_START_MS = Number(process.env.PCB_AFTER_START_MS || 200);

function resolveBoard() {
  if (process.env.PCB_BOARD) {
    return process.env.PCB_BOARD;
  }
  let dir = __dirname;
  for (let i = 0; i < 10; i++) {
    const cands = [
      path.join(dir, "Samples", "Boards", "hqpcb", "01_tracks_vias.hqpcb"),
      path.join(dir, "Boards", "hqpcb", "01_tracks_vias.hqpcb"),
    ];
    for (const c of cands) {
      if (fs.existsSync(c) && fs.statSync(c).isFile()) {
        return c;
      }
    }
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  throw new Error("board sample not found; set PCB_BOARD to an absolute .hqpcb path");
}

const cli = createClientFactory();
cli.connect();

function pause() {
  cli.sleepMs(STEP_MS);
}

const board = resolveBoard();
cli.log(";; open " + board);
cli.wsOpen(board);
pause();
cli.cmdlet("rasternext.wait_open_follow 30000");
pause();
cli.cmdlet("zoomall");
pause();

cli.log(";; action-current (before) = " + cli.cmdlet("action.current"));
cli.cmdlet("layer_schema.select Conductor1");
cli.cmdlet("action.start route");
pause();
cli.log(";; action-current (after start) = " + cli.cmdlet("action.current"));

cli.cmdlet("action.input move-line 6 -6 18 -15 8");
cli.cmdlet("action.input move 18 -15");
cli.sleepMs(80);
cli.cmdlet("action.input click 18 -15");
pause();
cli.sleepMs(AFTER_START_MS);

cli.cmdlet("action.input move-line 18 -15 28 -10 10");
cli.cmdlet("action.input click 28 -10");
pause();

cli.cmdlet("action.input dbclick 28 -10");
pause();

cli.cmdlet("action.cancel");
pause();

cli.log(";; action-current (after via+cancel) = " + cli.cmdlet("action.current"));
cli.cmdlet("zoomall");
pause();
cli.log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall");
