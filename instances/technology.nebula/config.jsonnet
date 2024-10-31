{
  project+: {
    fullName: "technology.nebula",
    displayName: "Eclipse Nebula",
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
    ],
  },
  seLinuxLevel: "s0:c49,c19",
}
