{
  project+: {
    fullName: "ee4j.eclipselink",
    displayName: "EclipseLink",
    // 1+4 https://bugs.eclipse.org/bugs/show_bug.cgi?id=564240
    resourcePacks: 5,
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "docker-workflow",
      "envinject",
      "embeddable-build-status",
    ],
  },
  seLinuxLevel: "s0:c36,c0",
}
