local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.lsp4j", "Eclipse LSP4J") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "gradle",
      ]
    }
  },
}
