/**
 * move_component 样例：开板 → 启动工具 → 框选器件 → 参考点 → 跟手 → 放下 → 保存。
 *
 * 板：02_components_pads（R1@12,-12；C1@28,-12）。
 * 接口走 hqeda_client 封装（startAction / mouseBoxSelect / mouseClick…），不直接拼 cmdlet。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/13_action_move_component.js
 */
"use strict";

const { createConnection } = require("hqeda_client");

const cli = createConnection(true);
const board = cli.resolveFile("Samples/Boards/hqpcbx/02_components_pads.hqpcbx");

cli.openAndWait(board, 30000);
cli.zoomAll();
cli.startAction("move_component");

// 左→右框选 R1+C1（Intersect）。
cli.mouseBoxSelect(8, -16, 32, -8, 10);

// 参考点：R1 中心；click 在动作切换后不再二次 pick。
cli.mouseClick(12, -12);

// 跟手平移约 +6,+6 mm 后放下。
cli.mouseMoveEx(12, -12, 18, -6, 12);
cli.mouseClick(18, -6);

cli.save();
cli.zoomAll();
