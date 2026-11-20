/**
 * @file plugin.js
 * @brief Js 样例目录内嵌小程序：对话框经 mp.slot 与主脚本交互。
 */
const CMD = "js_mp_open_board";

function openBundle(mp, bundleId, ctx) {
  try {
    var r = mp.showMPModal(bundleId, undefined, ctx || {});
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
      () => {
        var prompt = "请选择 .hqpcb / .hqpcbx";
        try {
          if (typeof rt.executeCmdlet === "function") {
            var p = rt.executeCmdlet("mp.slot.get key=" + encodeURIComponent("prompt"));
            if (p && typeof p.then === "function") {
              return p
                .then(function (text) {
                  if (text) prompt = String(text);
                  return openBundle(mp, "open_board", {
                    prompt: prompt,
                    status: prompt,
                  });
                })
                .catch(function () {
                  return openBundle(mp, "open_board", {
                    prompt: prompt,
                    status: prompt,
                  });
                });
            }
            if (p) prompt = String(p);
          }
        } catch (e) {}
        return openBundle(mp, "open_board", { prompt: prompt, status: prompt });
      },
      "Script Js MP Open Board",
      "Samples/Scripts/Js/12_mp_open_board；经 mp.slot 与主脚本交互"
    );
  },
});
