local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.lsp4mp", "Eclipse LSP4MP") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "blueocean",
        "embeddable-build-status",
      ],
    },
  },
}
