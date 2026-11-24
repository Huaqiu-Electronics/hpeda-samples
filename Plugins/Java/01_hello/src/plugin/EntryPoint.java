package plugin;

import com.huaqiu.pcb.sdk.PluginLifecycleEvents;
import com.huaqiu.pcb.sdk.PluginRuntime;

import java.util.Arrays;

/**
 * Samples 最小 Java 插件入口。
 *
 * <p>构建：{@code mvn -q package}（在 {@code Samples/Plugins/Java/01_hello}）。
 * 加载：{@code loadplugin Samples/Plugins/Java/01_hello/plugin.yaml}
 */
public final class EntryPoint {
    private static final String CMD_HELLO = "samples_java_hello";
    private static boolean sAppRegistered = false;

    private EntryPoint() {
    }

    public static void initialize(PluginRuntime runtime, String[] args) {
        runtime.logInfo("[samples.java.hello] initialize args=" + Arrays.toString(args));
        PluginLifecycleEvents.register(
                runtime,
                new PluginLifecycleEvents.Handlers()
                        .onAppInit((topic, payload) -> registerApp(runtime)));
    }

    private static void registerApp(PluginRuntime runtime) {
        if (sAppRegistered) {
            return;
        }
        sAppRegistered = true;
        runtime.registerCommand(
                CMD_HELLO,
                (cmdArgs) -> {
                    runtime.showMessage(
                            "Samples Java",
                            "Hello from Samples/Plugins/Java/01_hello",
                            0,
                            4000);
                    return 0;
                },
                "Samples Java Hello",
                "Minimal Java plugin sample");
        runtime.logInfo("[samples.java.hello] registered " + CMD_HELLO);
    }
}
