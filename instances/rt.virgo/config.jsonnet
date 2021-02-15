{
  project+: {
    fullName: "rt.virgo",
    displayName: "Eclipse Virgo",
  },
  jenkins+: {
    plugins+: [
      "gradle",
      "jacoco",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
  gradle+: {
    generate: true,
  },
}
