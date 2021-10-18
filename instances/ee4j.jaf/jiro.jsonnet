local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jaf", "Jakarta Activation") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light",
      plugins+: [
        "copyartifact",
      ],
    },
  }
}
