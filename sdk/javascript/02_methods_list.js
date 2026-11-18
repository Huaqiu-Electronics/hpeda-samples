#!/usr/bin/env node
"use strict";
const { resolvePipe, loadSdk } = require("./_env");

async function main() {
  const { pipe, gui } = resolvePipe(process.argv);
  const { createPcbFlightIPC } = loadSdk();
  const cli = createPcbFlightIPC();
  await cli.connect(pipe, { gui });
  const catalog = await cli.methodsList();
  console.log("# pipe=" + cli.pipe + " role=" + cli.peerRole);
  console.log(String(catalog).trimEnd());
  const lines = String(catalog).split("\n");
  const core = lines.filter((l) => l.includes("surface=core")).length;
  const ix = lines.filter((l) => l.includes("surface=interactive")).length;
  console.log("# count core=" + core + " interactive=" + ix);
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
