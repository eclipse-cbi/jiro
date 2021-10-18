local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("iot.4diac", "Eclipse 4diac") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "cmakebuilder",
        "copyartifact",
        "cppcheck",
      ],
    },
  }
}
