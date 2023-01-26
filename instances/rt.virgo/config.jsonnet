{
  project+: {
    fullName: "rt.virgo",
    displayName: "Eclipse Virgo",
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "gradle",
      "jacoco",
    ],
  },
  gradle+: {
    generate: true,
  },
}
