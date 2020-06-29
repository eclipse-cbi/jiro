{
  project+: {
    fullName: "ee4j.eclipselink",
    displayName: "EclipseLink",
    resourcePacks: 1 + 4, // https://bugs.eclipse.org/bugs/show_bug.cgi?id=564240
  },
  maven+: {
    files+: {
      "settings.xml"+: {
        servers+: {
          ossrh+: {
            // default is https://jakarta.oss.sonatype.org for ee4j projects
            // except for eclipselink
            nexusProUrl: "https://oss.sonatype.org",
          },
        },
      },
    },
  },
}
