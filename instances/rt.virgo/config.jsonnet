{
  project+: {
    fullName: "rt.virgo",
    displayName: "Eclipse Virgo",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "gradle",
      "jacoco",
    ],
  },
  gradle+: {
    generate: true,
  },
  seLinuxLevel: "s0:c53,c17",
}
