local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.jakartaee-tck", "Eclipse Jakarta EE TCK") {
  "config.json"+: {
    project+: {
      resourcePacks: 52,
    },
    jenkins+: {
      maxConcurrency: 25,
      agentConnectionTimeout: 300,
      theme: "quicksilver-light",
      plugins+: [
        "blueocean",
        "copyartifact",
        "description-setter",
        "envinject",
        "extended-choice-parameter",
        "groovy",
      ],
    },
  }
}
