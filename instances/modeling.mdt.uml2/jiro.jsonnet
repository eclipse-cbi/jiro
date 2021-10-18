local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.mdt.uml2", "Eclipse MDT UML2") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "buckminster",
      ]
    }
  }
}
