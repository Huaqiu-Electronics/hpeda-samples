#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, checkEnv, loadSdk } = require("./helper");

async function main() {
  const { gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "tracks");
  const { createConnection } = loadSdk();
  const cli = await createConnection(gui);
  if (checkEnv(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  console.log("pipe=" + cli.pipe);
  console.log("--- ws.open ---");
  console.log(String(await cli.wsOpen(path)).trimEnd());
  const token = "samples-sdk-rw";
  console.log("--- design.lease / set / get / release ---");
  console.log(String(await cli.designLease(token)).trimEnd());
  console.log(String(await cli.designSet("sample.note", "from-samples-sdk", token)).trimEnd());
  console.log("sample.note=" + (await cli.designGet("sample.note")));
  console.log(String(await cli.designRelease(token)).trimEnd());
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
