local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("rt.rap", "Eclipse RAP") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  },
}
