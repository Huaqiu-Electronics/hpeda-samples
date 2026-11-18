#!/usr/bin/env node
"use strict";
const { resolvePipe, loadSdk } = require("./_env");

async function main() {
  const { pipe, gui, rest } = resolvePipe(process.argv);
  const key = rest[0] || "sample.theme";
  const value = rest[1] || "dark";
  const { createPcbFlightIPC } = loadSdk();
  const cli = createPcbFlightIPC();
  await cli.connect(pipe, { gui });
  console.log(String(await cli.configSet(key, value)).trimEnd());
  const got = await cli.configGet(key);
  console.log(key + "=" + got);
  cli.disconnect();
  if (got !== value) process.exit(1);
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
