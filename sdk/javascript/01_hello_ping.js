#!/usr/bin/env node
"use strict";
const { resolvePipe, loadSdk } = require("./_env");

async function main() {
  const { pipe, gui } = resolvePipe(process.argv);
  const { createPcbFlightIPC } = loadSdk();
  const cli = createPcbFlightIPC();
  await cli.connect(pipe, { gui });
  const echo = await cli.ping("samples-sdk-01");
  const caps = cli.peerCaps || {};
  console.log("pipe=" + cli.pipe);
  console.log("role=" + cli.peerRole);
  console.log("ping=" + echo);
  console.log(
    "caps interactive=" +
      caps.interactive +
      " workspace=" +
      caps.workspace +
      " design=" +
      caps.design
  );
  cli.disconnect();
}

main().catch((e) => {
  console.error(e && e.stack ? e.stack : e);
  process.exit(1);
});
