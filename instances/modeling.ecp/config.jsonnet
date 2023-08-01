{
  project+: {
    fullName: "modeling.ecp",
    displayName: "Eclipse EMF Client Platform",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "jacoco",
    ],
  },
}
