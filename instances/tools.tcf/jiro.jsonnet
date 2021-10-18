local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("tools.tcf", "Eclipse Target Communication Framework") {
  "config.json"+: {
    project+: {
      unixGroupName: "tools.cdt.tcf",
    },
    jenkins+: {
      plugins+: [
        "warnings-ng",
      ]
    }
  },
}
