local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.tracecompass", "Eclipse Trace Compass") {
  "config.json"+: {
    project+: {
      resourcePacks: 2
    },
  },
}
