#!/usr/bin/env node
"use strict";
/**
 * DoGet objects.list / query.table；Node 若拿不到 Arrow body 则回退 DoAction 计数。
 */
const { resolvePipe, boardPath, requireWsDesign, loadSdk } = require("./_env");

async function main() {
  const { pipe, gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "all_basics");
  const { createPcbFlightIPC, api } = loadSdk();
  const cli = createPcbFlightIPC();
  await cli.connect(pipe, { gui });
  if (requireWsDesign(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  await cli.wsOpen(path);
  console.log("pipe=" + cli.pipe + " path=" + path);

  let trackRows = 0;
  try {
    const table = await cli.doGet("method=objects.list\nkind=tracks\n");
    if (table && table.numRows > 0) trackRows = table.numRows;
  } catch (_) {}
  if (!trackRows) {
    trackRows = (api.parseTracesV1(await cli.doAction("board.tracks", "")).tracks || []).length;
  }
  console.log("tracks_rows=" + trackRows);

  let viaRows = 0;
  try {
    const table = await cli.doGet("method=objects.list\nkind=vias\n");
    if (table && table.numRows > 0) viaRows = table.numRows;
  } catch (_) {}
  if (!viaRows) {
    viaRows = api.parseListV1(await cli.doAction("board.vias", "")).items.length;
  }
  console.log("vias_rows=" + viaRows);

  try {
    await cli.doGet("method=query.table\ntable=sqlite_master\n");
    console.error("error: expected table_not_allowed");
    process.exit(2);
  } catch (e) {
    const msg = String(e && e.message ? e.message : e);
    console.log("reject_ok=" + (msg.includes("table_not_allowed") ? "table_not_allowed" : msg));
  }
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
