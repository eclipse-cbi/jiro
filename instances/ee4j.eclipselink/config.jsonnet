{
  project+: {
    fullName: "ee4j.eclipselink",
    displayName: "EclipseLink",
    resourcePacks: 1 + 4, // https://bugs.eclipse.org/bugs/show_bug.cgi?id=564240
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "docker-workflow",
      "envinject",
    ],
  },
}
