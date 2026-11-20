/**
 * 弹出工程打开对话框选板，再 openAndWait 打开。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/11_choose_file.js
 *
 * 连接：脚本模式 createConnection（宿主桥）；
 * 选文件：cli.chooseFile（file.choose）；取消时抛错。
 */
"use strict";

const { createConnection } = require("hqeda_client");

const cli = createConnection(true);

cli.log(";; chooseFile: pick a .hqpcb / .hqpcbx …");
const board = cli.chooseFile();
cli.log(";; chosen " + board);

cli.openAndWait(board, 30000);
cli.zoomAll();
cli.log(";; open ok");
