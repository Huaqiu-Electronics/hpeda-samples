/**
 * 对齐 Lisp 09_action_route：route → 途经点 → 末点再点打 via → cancel 退出 → zoomall。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/09_action_route.js
 *
 * 连接：脚本模式 createConnection（宿主桥）；
 * 开板：cli.open（与 SDK ClientFactory 同名）。
 */
"use strict";

const { createConnection } = require("hqeda_client");

const STEP_MS = Number(process.env.PCB_STEP_MS || 60);
const AFTER_START_MS = Number(process.env.PCB_AFTER_START_MS || 200);

const cli = createConnection(true);

const board =
  process.env.PCB_BOARD ||
  cli.resolveFile("Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx");
cli.log(";; open " + board);
cli.openAndWait(board, 30000);
cli.sleepMs(STEP_MS);
cli.zoomAll();
cli.sleepMs(STEP_MS);

cli.log(";; action-current (before) = " + cli.currentAction());
cli.selectLayer("Conductor1");
cli.startAction("route");
cli.sleepMs(STEP_MS);
cli.log(";; action-current (after start) = " + cli.currentAction());

cli.mouseMoveEx(6, -6, 18, -15, 8);
cli.sleepMs(80);
cli.mouseClick(18, -15);
cli.sleepMs(STEP_MS);
cli.sleepMs(AFTER_START_MS);

cli.mouseMoveEx(18, -15, 28, -10, 10);
cli.mouseClick(28, -10);
cli.sleepMs(STEP_MS);

cli.mouseDBClick(28, -10);
cli.sleepMs(STEP_MS);

cli.cancelAction();
cli.sleepMs(STEP_MS);

cli.log(";; action-current (after via+cancel) = " + cli.currentAction());
cli.zoomAll();
cli.sleepMs(STEP_MS);
cli.log(";; done: routed via (18,-15)→(28,-10) + dblclick via + cancel + zoomall");
