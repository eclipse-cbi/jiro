local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("ee4j.eclipselink","EclipseLink") {
  "config.json"+: {
    project+: {
      resourcePacks: 1 + 4, // https://bugs.eclipse.org/bugs/show_bug.cgi?id=564240
    },
    jenkins+: {
      plugins+: [
        "copyartifact",
        "docker-workflow",
        "envinject",
        "embeddable-build-status",
      ],
    },
  },
}