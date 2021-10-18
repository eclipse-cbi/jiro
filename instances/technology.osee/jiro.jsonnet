local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.osee", "Eclipse OSEE") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "nodejs",
      ],
    },
  },
}
