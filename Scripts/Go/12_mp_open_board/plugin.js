/**
 * @file plugin.js
 * @brief Go 样例目录内嵌小程序：对话框经 mp.slot 与主脚本交互。
 */
const CMD = "go_mp_open_board";

function openBundle(mp, bundleId) {
  try {
    // 首屏 data 由页面 onLoad 再读 mp.slot.prompt；此处只打开页。
    var r = mp.showMPModal(bundleId);
    if (!r || !r.ok) {
      return 0;
    }
    return Number(r.dialogId) || 0;
  } catch (e) {
    return 1;
  }
}

App({
  onAppInit() {
    const rt = this.runtime;
    const mp = rt.startMiniProgram({
      methods: {
        slotGet: function (key) {
          const k = String(key || "").trim() || "result";
          if (typeof rt.executeCmdlet !== "function") {
            return Promise.reject(new Error("executeCmdlet unavailable"));
          }
          return rt.executeCmdlet("mp.slot.get key=" + encodeURIComponent(k));
        },
        slotPut: function (key, value) {
          const k = String(key || "").trim() || "result";
          const v = String(value == null ? "" : value);
          if (typeof rt.executeCmdlet !== "function") {
            return Promise.reject(new Error("executeCmdlet unavailable"));
          }
          return rt.executeCmdlet(
            "mp.slot.put key=" +
              encodeURIComponent(k) +
              " value=" +
              encodeURIComponent(v)
          );
        },
        slotFinish: function () {
          if (typeof rt.executeCmdlet !== "function") {
            return Promise.reject(new Error("executeCmdlet unavailable"));
          }
          return rt.executeCmdlet("mp.slot.finish");
        },
        slotCancel: function () {
          if (typeof rt.executeCmdlet !== "function") {
            return Promise.reject(new Error("executeCmdlet unavailable"));
          }
          return rt.executeCmdlet("mp.slot.cancel");
        },
      },
    });
    rt.registerCommandCallback(
      CMD,
      () => openBundle(mp, "open_board"),
      "Script Go MP Open Board",
      "Samples/Scripts/Go/12_mp_open_board；经 mp.slot 与主脚本交互"
    );
  },
});
