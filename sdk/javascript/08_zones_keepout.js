#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "keepout");
  const { createConnection, api } = loadSdk();
  const cli = await createConnection(gui);
  if (checkEnv(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  await cli.wsOpen(path);
  console.log("pipe=" + cli.pipe + " path=" + path);
  const zones = api.parseListV1(await cli.doAction("board.zones", "")).items.map((r) => new api.Zone(r));
  console.log("zone_count=" + zones.length);
  zones.slice(0, 10).forEach((z) => {
    console.log("  id=" + z.id + " name=" + JSON.stringify(z.name) + " net=" + JSON.stringify(z.net));
  });
  const drawings = api
    .parseListV1(await cli.doAction("board.drawings", ""))
    .items.map((r) => new api.Drawing(r));
  console.log("drawing_count=" + drawings.length);
  const bboxRaw = await cli.doAction("board.bounding_box", "");
  console.log("bbox_raw=" + String(bboxRaw).trim().split("\n")[0]);
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
