local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.efxclipse", "Eclipse e(fx)clipse") {
  "config.json"+: {
    gradle+: {
      generate: true
    },
  },
}
