/**
 * 主脚本 ↔ 本目录小程序：传 prompt，等对话框回传路径，再 openAndWait。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/12_mp_open_board/12_mp_open_board.js
 */
"use strict";

const { createConnection } = require("hqeda_client");

const cli = createConnection(true);

const manifest = cli.resolveFile(
  "Samples/Scripts/Js/12_mp_open_board/plugin.yaml"
);

cli.log(";; loadplugin " + manifest);
cli.cmdlet("loadplugin " + manifest);

// 脚本 → 小程序：写入提示文案。
cli.cmdlet("mp.slot.clear");
cli.cmdlet(
  "mp.slot.put key=" +
    encodeURIComponent("prompt") +
    " value=" +
    encodeURIComponent("JS 脚本：请选一块样板板再 OK")
);

cli.log(";; open MP dialog (js_mp_open_board)");
cli.cmdlet("js_mp_open_board");

// 小程序 → 脚本：阻塞等待 result（用户 OK / Cancel）。
cli.log(";; wait mp.slot.result …");
const board = String(cli.cmdlet("mp.slot.wait 300000") || "").trim();
if (!board) {
  throw new Error("empty board path from mp.slot");
}
cli.log(";; mp returned " + board);

cli.openAndWait(board, 30000);
cli.zoomAll();
cli.log(";; open ok");
