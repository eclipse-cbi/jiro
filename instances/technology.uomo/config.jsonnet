{
  project+: {
    fullName: "technology.uomo",
    displayName: "Eclipse UOMo"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c56,c25",
}
