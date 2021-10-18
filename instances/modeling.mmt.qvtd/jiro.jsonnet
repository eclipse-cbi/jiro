local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.mmt.qvtd", "Eclipse QVTd") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light"
    }
  }
}
