{
  project+: {
    fullName: "modeling.acceleo",
    displayName: "Eclipse Acceleo",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "jacoco",
      "warnings-ng",
    ],
  },
}
