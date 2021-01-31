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
  gradle+: {
    generate: true,
  },
}
