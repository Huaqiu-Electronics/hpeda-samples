/**
 * 对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/09_action_route.js
 *
 * 纸面 mm：VCC via @ (18,-15)；途经点/打孔点 @ (28,-10)。
 */
"use strict";

const fs = require("fs");
const path = require("path");
const pcb = require("pcb_host");

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

function pause() {
  pcb.sleepMs(STEP_MS);
}

const board = resolveBoard();
pcb.log(";; open " + board);
pcb.cmdlet("project.open path=" + encodeURIComponent(board));
pause();
pcb.cmdlet("rasternext.wait_open_follow 30000");
pause();
pcb.cmdlet("zoomall");
pause();

pcb.log(";; action-current (before) = " + pcb.cmdlet("action.current"));
// 先切到 Conductor1（传层名），避免 From/To 在底层倒置导致末点 dbclick 打孔失败。
pcb.cmdlet("layer_schema.select Conductor1");
pcb.cmdlet("action.start route");
pause();
pcb.log(";; action-current (after start) = " + pcb.cmdlet("action.current"));

pcb.cmdlet("action.input move-line 6 -6 18 -15 8");
pcb.cmdlet("action.input move 18 -15");
pcb.sleepMs(80);
pcb.cmdlet("action.input click 18 -15");
pause();
pcb.sleepMs(AFTER_START_MS);

pcb.cmdlet("action.input move-line 18 -15 28 -10 10");
pcb.cmdlet("action.input click 28 -10");
pause();

// 末点 dbclick：双击打 via。
pcb.cmdlet("action.input dbclick 28 -10");
pause();

pcb.cmdlet("action.cancel");
pause();

pcb.log(";; action-current (after via+cancel) = " + pcb.cmdlet("action.current"));
pcb.cmdlet("zoomall");
pause();
pcb.log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall");
