local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ecd.glsp", "Eclipse GLSP") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "github-checks",
      ],
    },
  },
}