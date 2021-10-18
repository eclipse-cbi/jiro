local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("automotive.mdmbl", "Eclipse MDM|BL") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "gradle",
      ],
    },
  },
}
