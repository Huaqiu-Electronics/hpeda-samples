/**
 * 对齐 Lisp 10_pick_highlight_lock：pick → highlight/dehighlight → lock/unlock → hide。
 *
 * 对齐菜单：
 *   View/Highlight、View/Dehighlight
 *   Edit/Lock、Edit/Unlock
 * 流程：pickAt 选中后 startAction，工具对当前选择集立即 apply，再 cancel 退出并切回 Conductor1。
 *
 * Usage:
 *   js-load Samples/Scripts/Js/10_pick_highlight_lock.js
 *
 * 连接：脚本模式 createConnection（宿主桥）；
 * 开板：cli.open（与 SDK ClientFactory 同名）。
 */
"use strict";

const { createConnection } = require("hqeda_client");

const STEP_MS = Number(process.env.PCB_STEP_MS || 60);
const PICK_X = Number(process.env.PCB_PICK_X || 12);
const PICK_Y = Number(process.env.PCB_PICK_Y || -20);

const cli = createConnection(true);

const board =
  process.env.PCB_BOARD ||
  cli.resolveFile("Samples/Boards/hqpcbx/01_tracks_vias.hqpcbx");
cli.log(";; open " + board);
cli.openAndWait(board, 30000);
cli.sleepMs(STEP_MS);
cli.zoomAll();
cli.sleepMs(STEP_MS);

// 先切到 Conductor1，保证 (12,-20) 走线可命中。
cli.selectLayer("Conductor1");
cli.sleepMs(STEP_MS);

function pickOrThrow() {
  cli.log(";; pick at (" + PICK_X + "," + PICK_Y + ")");
  const ids = cli.pickAt(PICK_X, PICK_Y);
  cli.log(";; pick ids = " + JSON.stringify(ids));
  if (!ids.length) {
    throw new Error("pick miss at (" + PICK_X + "," + PICK_Y + ")");
  }
  return ids;
}

/** cancel 后切回 Conductor1，避免工具退出后层态漂移导致后续 pick 落空。 */
function cancelToConductor1() {
  cli.cancelAction();
  cli.selectLayer("Conductor1");
  cli.sleepMs(STEP_MS);
}

// 选中文档坐标处对象（与菜单先选中再点 Highlight/Lock 一致）。
pickOrThrow();

// View/Highlight：对当前选择集上色，工具保持激活，cancel 退出。
cli.log(";; highlight (menu View/Highlight)");
cli.startAction("highlight");
cli.sleepMs(STEP_MS);
cancelToConductor1();

// apply 后选择集已清；再 pick 一次做 Dehighlight。
pickOrThrow();
cli.log(";; dehighlight (menu View/Dehighlight)");
cli.startAction("dehighlight");
cli.sleepMs(STEP_MS);
cancelToConductor1();

// Edit/Lock → Edit/Unlock。
pickOrThrow();
cli.log(";; lock (menu Edit/Lock)");
cli.startAction("lock");
cli.sleepMs(STEP_MS);
cancelToConductor1();

pickOrThrow();
cli.log(";; unlock (menu Edit/Unlock)");
cli.startAction("unlock");
cli.sleepMs(STEP_MS);
cancelToConductor1();

// 再 pick 后 hideItems（内部 setStaticObjectsVisibleByIds）。
const pickIds = pickOrThrow();
const hideOut = cli.hideItems(pickIds);
cli.log(";; hideItems = " + hideOut);
cli.sleepMs(STEP_MS);

cli.log(";; done: pick + highlight/dehighlight + lock/unlock + hide");
