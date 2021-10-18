local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("soa.winery", "Eclipse Winery") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "nodejs",
      ],
    },
  },
}
