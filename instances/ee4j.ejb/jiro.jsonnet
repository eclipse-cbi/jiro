local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.ejb", "Jakarta Enterprise Beans") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "copyartifact",
      ],
    },
  },
}