local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("modeling.mdt.ocl", "Eclipse OCL") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light",
      plugins+: [
        "buckminster",
      ],
    }
  }
}
