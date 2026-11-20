#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "diffpair");
  const { createConnection, api } = loadSdk();
  const cli = await createConnection(gui);
  if (checkEnv(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  await cli.wsOpen(path);
  console.log("pipe=" + cli.pipe + " path=" + path);
  const dsBody = await cli.doAction("board.design_settings", "");
  console.log("design_settings=" + String(dsBody).trim().split("\n").slice(0, 3).join(" | "));
  const classes = api
    .parseListV1(await cli.doAction("board.net_classes", ""))
    .items.map((r) => new api.NetClass(r));
  console.log("net_class_count=" + classes.length);
  classes.forEach((nc) => {
    console.log("  " + JSON.stringify(nc.name) + " members=" + nc.member_count);
  });
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
