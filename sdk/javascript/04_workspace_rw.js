#!/usr/bin/env node
"use strict";
const { resolvePipe, boardPath, requireWsDesign, loadSdk } = require("./_env");

async function main() {
  const { pipe, gui, rest } = resolvePipe(process.argv);
  const path = boardPath(rest[0], "tracks");
  const { createPcbFlightIPC } = loadSdk();
  const cli = createPcbFlightIPC();
  await cli.connect(pipe, { gui });
  if (requireWsDesign(cli)) {
    cli.disconnect();
    process.exit(1);
  }
  console.log("pipe=" + cli.pipe);
  console.log("--- ws.open ---");
  console.log(String(await cli.wsOpen(path)).trimEnd());
  console.log("gen=" + (await cli.wsGen()));
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
